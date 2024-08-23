//===- llvm/CodeGen/GlobalISel/CDFGPass.cpp - CDFGPass ---==//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
/// \file
/// This file implements the CDFGPass class.
//===----------------------------------------------------------------------===//

#include <iostream>
#include <mgclient.h>

#include "llvm/CodeGen/GlobalISel/CDFGPass.h"
#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/ADT/ScopeExit.h"
#include "llvm/Analysis/LazyBlockFrequencyInfo.h"
#include "llvm/Analysis/ProfileSummaryInfo.h"
#include "llvm/CodeGen/GlobalISel/GISelKnownBits.h"
#include "llvm/CodeGen/GlobalISel/InstructionSelector.h"
#include "llvm/CodeGen/GlobalISel/LegalizerInfo.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/CodeGen/GlobalISel/Utils.h"
#include "llvm/CodeGen/ISDOpcodes.h"
#include "llvm/CodeGenTypes/LowLevelType.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineMemOperand.h"
#include "llvm/CodeGen/MachineOptimizationRemarkEmitter.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/TargetLowering.h"
#include "llvm/CodeGen/TargetOpcodes.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/CodeGen/TargetSubtargetInfo.h"
#include "llvm/Config/config.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/CodeGenCoverage.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/TypeSize.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Transforms/Utils/PredicateInfo.h"
#include <memory>
#include <sstream>
#include <string>
#include <utility>
#include <unordered_set>

#include <vector>


#define PURGE_DB false
#define FORCE_ENABLE false
// #define FORCE_ENABLE true
#define DEBUG false  // TODO: use -debug flag of llvm
#define NOOP false

#define CDFG_STAGE CDFG_STAGE_3

#define DEBUG_TYPE "cdfg-pass"

using namespace llvm;

// #define CDFG_ENABLE_DEFAULT true

static cl::opt<std::string>
    MemgraphHost("cdfg-memgraph-host", cl::init("localhost"),
                   cl::desc("Hostname of Memgraph server"));
static cl::opt<int>
    MemgraphPort("cdfg-memgraph-port", cl::init(7687),
                   cl::desc("Port of Memgraph server"));
static cl::opt<int>
    StageMask("cdfg-stage-mask", cl::init(CDFG_STAGE_3),
                   cl::desc("Chooses ISel stages where pass is executed (1,2,4,8,16,32 or combinations)"));
static cl::opt<bool>
    MemgraphPurge("cdfg-memgraph-purge", cl::desc("Purge Memgraph database"));
static cl::opt<std::string>
    MemgraphSession("cdfg-memgraph-session", cl::init("default"),
                   cl::desc("Session name to be added as node attribute"));
static cl::opt<bool>
    EnablePass("cdfg-enable", cl::desc("Enable CDFGPass"));

typedef enum OpType {NONE, INPUT, OUTPUT, OPERATOR, CONSTANT} op_type_t;

std::string op_type_to_str(op_type_t op_type) {
  switch (op_type) {
    case NONE:
      return "none";
    case INPUT:
      return "input";
    case OUTPUT:
      return "output";
    case OPERATOR:
      return "operator";
    case CONSTANT:
      return "constant";
    default:
      return "unkown";
  };
  return "invalid";
}

std::string get_bb_name(MachineBasicBlock *bb) {
    std::string str;
    raw_string_ostream OS(str);
    bb->printAsOperand(OS, false);
    return OS.str();
}

template <typename LLVM_Type>
std::string llvm_to_string(LLVM_Type *obj)
{
    std::string str;
    raw_string_ostream OS(str);
    OS << *obj << "\n";
    return OS.str();
}

std::string reg_to_string(int Reg, const TargetRegisterInfo *TRI)
{
    std::string str;
    raw_string_ostream OS(str);
    OS << printReg(Reg, TRI);
    return OS.str();
}

bool isUsedOutsideOfBlock(MachineInstr* MI, MachineBasicBlock* MBB, MachineRegisterInfo* MRI) {
  for (const MachineOperand &MO : MI->uses()) {
    if (MO.getType() == MachineOperand::MO_Register) {  // TODO: isReg
      auto Reg = MO.getReg();
      if (Reg.isVirtual()) {
        MachineInstr *MI_ = MRI->getVRegDef(Reg);
        if (!MI_) continue;
        MachineBasicBlock *ParentMBB = MI_->getParent();
        if (ParentMBB != MBB) {
          return true;
        }
      } else {
        // TODO
      }
    }
  }
  return false;
}

bool isOutputForBasicBlock(MachineInstr* MI, MachineRegisterInfo* MRI) {
  if (MI->mayStore()) {
    return true;
  }
  MachineBasicBlock *MBB = MI->getParent();
	if (isUsedOutsideOfBlock(MI, MBB, MRI))
		return true;
  for (MachineInstr &TermMI :
       llvm::make_range(MBB->getFirstInstrTerminator(), MBB->instr_end())) {
    if (TermMI.isReturn() || TermMI.isBranch()) {
      for (const MachineOperand &MO : TermMI.operands()) {
        if (MO.isReg()) {
          auto Reg = MO.getReg();
          if (Reg.isVirtual()) {
            MachineInstr *OpMI = MRI->getVRegDef(Reg);
            if (OpMI == MI) {
              return true;
            }
          } else {
            // TODO
          }
        }
      }
    }
  }
  return false;
}

mg_session *connect_to_db(const char *host, uint16_t port)
        {
            mg_init();
#if DEBUG
            // printf("mgclient version: %s\n", mg_client_version());
            llvm::outs() << "mgclient version: " << mg_client_version() << "\n";
#endif

            mg_session_params *params = mg_session_params_make();
            if (!params)
            {
                // fprintf(stderr, "failed to allocate session parameters\n");
                llvm::errs() << "failed to allocate session parameters\n";
                exit(1);
            }
            mg_session_params_set_host(params, host);
            mg_session_params_set_port(params, port);
            mg_session_params_set_sslmode(params, MG_SSLMODE_DISABLE);

            mg_session *session = NULL;
            int status = mg_connect(params, &session);
            mg_session_params_destroy(params);
            if (status < 0)
            {
                // printf("failed to connect to Memgraph: %s\n", mg_session_error(session));
                llvm::errs() << "failed to connect to Memgraph: " << mg_session_error(session) << "\n";
                mg_session_destroy(session);
                exit(1);
            }
            return session;
        }

  void disconnect(mg_session *session)
  {
      mg_session_destroy(session);
      mg_finalize();
  }



  void exec_qeury(mg_session *session, const char *query)
  {
#if DEBUG
      outs() << "query: " << query << "\n";
#endif
#if NOOP
      return;  // skip pushing to db
#endif
      if (mg_session_run(session, query, NULL, NULL, NULL, NULL) < 0)
      {
          llvm::errs() << "failed to execute query: " << query << " mg error: " << mg_session_error(session) << "\n";
          mg_session_destroy(session);
          exit(1);
      }
      if (mg_session_pull(session, NULL))
      {
          llvm::errs() << "failed to pull results of the query: " << mg_session_error(session) << "\n";
          mg_session_destroy(session);
          exit(1);
      }

      int status = 0;
      mg_result *result;
      int rows = 0;
      while ((status = mg_session_fetch(session, &result)) == 1)
      {
          rows++;
      }

      if (status < 0)
      {
          llvm::errs() << "error occurred during query execution: " << mg_session_error(session) << "\n";
      }
      else
      {
#if DEBUG
          printf("query executed successfuly and returned %d rows\n", rows);
#endif

      }
  }
  std::string sanitize_str(std::string str) {
      const std::string illegal_chars = "\n\"\\\'\t()[]{}~";
      for (char c : illegal_chars) {
          replace(str.begin(), str.end(), c, '_');
      }
      return str;
  }

  // void connect_bbs(mg_session *session, MachineBasicBlock *first_bb, MachineBasicBlock *second_bb, std::string f_name, std::string module_name)
  // {
  //     // std::string frist_bb_str = llvm_to_string(first_bb);
  //     // std::string second_bb_str = llvm_to_string(second_bb);
  //     // first_bb_str = sanitize_str(first_bb_str);
  //     // second_bb_str = sanitize_str(second_bb__str);

  //     // MERGE: create if not exist else match
  //     std::string store_first = "MERGE (first_bb {name: '" + get_bb_name(first_bb) + "', func_name: '" + f_name + "', basic_block: '" + get_bb_name(first_bb) + "', module_name: '" + module_name + "'})";
  //     std::string set_frist_code = " SET first_bb.code =  '" + sanitize_str(llvm_to_string(first_bb)) + "'";
  //     std::string store_second = " MERGE (second_bb {name: '" + get_bb_name(second_bb) + "', func_name: '" + f_name + "', basic_block: '" + get_bb_name(second_bb) + "', module_name: '" + module_name + "'})";
  //     std::string set_second_code = " SET second_bb.code =  '" + sanitize_str(llvm_to_string(second_bb)) + "'";
  //     std::string rel = " MERGE (first_bb)-[:CFG]->(second_bb);";
  //     std::string qry = store_first + set_frist_code + store_second + set_second_code + rel;
  //     exec_qeury(session, qry.c_str());
  // }
  void create_bb(mg_session *session, MachineBasicBlock *bb, std::string f_name, std::string module_name, int stage)
  {
      unsigned bb_id = bb->getBBID()->BaseID;
      std::string store_bb = "MERGE (bb:BB {session: '" + MemgraphSession + "', stage: " + std::to_string(stage) + ", name: '" + get_bb_name(bb) + "', bb_id: " + std::to_string(bb_id) + ", func_name: '" + f_name + "', module_name: '" + module_name + "', kind: 'basicblock'})";
      std::string set_bb_code = " SET bb.code =  '" + sanitize_str(llvm_to_string(bb)) + "'";
      std::string qry = store_bb + set_bb_code;
      exec_qeury(session, qry.c_str());
  }

  void connect_bbs(mg_session *session, MachineBasicBlock *first_bb, MachineBasicBlock *second_bb, std::string f_name, std::string module_name, int stage)
  {
      // MERGE: create if not exist else match
      unsigned first_bb_id = first_bb->getBBID()->BaseID;
      unsigned second_bb_id = second_bb->getBBID()->BaseID;
      std::string match_first = "MATCH (first_bb:BB {session: '" + MemgraphSession + "', stage: " + std::to_string(stage) + ", name: '" + get_bb_name(first_bb) + "', bb_id: " + std::to_string(first_bb_id) + ", func_name: '" + f_name + "', module_name: '" + module_name + "', kind: 'basicblock'})";
      std::string match_second = "MATCH (second_bb:BB {session: '" + MemgraphSession + "', stage: " + std::to_string(stage) + ", name: '" + get_bb_name(second_bb) + "', bb_id: " + std::to_string(second_bb_id) + ", func_name: '" + f_name + "', module_name: '" + module_name + "', kind: 'basicblock'})";
      std::string rel = " MERGE (first_bb)-[:CFG]->(second_bb);";
      std::string qry = match_first + match_second + rel;
      exec_qeury(session, qry.c_str());
  }



  // void connect_insts(mg_session *session, std::string src_str, std::string src_op_name, std::string dst_str, std::string dst_op_name, std::string bb_name, std::string f_name, std::string module_name)
  // void connect_insts(mg_session *session, std::string src_str, std::string src_op_name, std::string dst_str, std::string dst_op_name, std::string parent_bb_name, std::string bb_name, std::string f_name, std::string module_name, std::string rel_type)
  // {
  //     // MERGE: create if not exist else match
  //     src_str = sanitize_str(src_str);
  //     dst_str = sanitize_str(dst_str);

  //     std::string store_src = "MERGE (src_inst {name: '" + src_op_name + "', inst: '" + src_str + "', func_name: '" + f_name + "', basic_block: '" + parent_bb_name + "', module_name: '" + module_name + "'})";
  //     std::string store_dst = "MERGE (dst_inst {name: '" + dst_op_name + "', inst: '" + dst_str + "', func_name: '" + f_name + "', basic_block: '" + bb_name + "', module_name: '" + module_name + "'})";
  //     std::string rel = "MERGE (src_inst)-[:" + rel_type + "]->(dst_inst);";
  //     std::string qry = store_src + '\n' + store_dst + '\n' + rel + '\n';
  //     exec_qeury(session, qry.c_str());
  // }
  void create_inst(mg_session *session, std::string code, std::string op_name, std::string op_type_str, std::string f_name, std::string bb_name, unsigned bb_id, std::string module_name, int stage)
  {
      code = sanitize_str(code);

      std::string store_inst = "MERGE (inst:INSTR {session: '" + MemgraphSession + "', stage: " + std::to_string(stage) + ", name: '" + op_name + "', inst: '" + code + "', func_name: '" + f_name + "', basic_block: '" + bb_name + "', bb_id: " + std::to_string(bb_id) + ", module_name: '" + module_name + "', kind: 'instruction', op_type: '" + op_type_str + "'})";
      std::string qry = store_inst + '\n';
      exec_qeury(session, qry.c_str());
  }
  void add_inst_preds(mg_session *session, std::string code, std::string op_name, std::string op_type_str, std::string f_name, std::string bb_name, unsigned bb_id, std::string module_name, int stage, bool mayLoad, bool mayStore, bool isPseudo, bool isReturn, bool isCall, bool isTerminator, bool isBranch, bool hasUnmodeledSideEffects, bool isCommutable)
  {
      code = sanitize_str(code);

      std::string match_inst = "MATCH (inst:INSTR {session: '" + MemgraphSession + "', stage: " + std::to_string(stage) + ", name: '" + op_name + "', inst: '" + code + "', func_name: '" + f_name + "', basic_block: '" + bb_name + "', bb_id: " + std::to_string(bb_id) + ", module_name: '" + module_name + "', kind: 'instruction', op_type: '" + op_type_str + "'})\n";
      std::string set_may_load = "SET inst.mayLoad = " + std::string(mayLoad ? "true": "false") + "\n";
      std::string set_may_store = "SET inst.mayStore = " + std::string(mayStore ? "true": "false") + "\n";
      std::string set_is_pseudo = "SET inst.isPseudo = " + std::string(isPseudo ? "true": "false") + "\n";
      std::string set_is_return = "SET inst.isReturn = " + std::string(isReturn ? "true": "false") + "\n";
      std::string set_is_call = "SET inst.isCall = " + std::string(isCall ? "true": "false") + "\n";
      std::string set_is_terminator = "SET inst.isTerminator = " + std::string(isTerminator ? "true": "false") + "\n";
      std::string set_is_branch = "SET inst.isBranch = " + std::string(isBranch ? "true": "false") + "\n";
      std::string set_has_unmodeled_side_effects = "SET inst.hasUnmodeledSideEffects = " + std::string(hasUnmodeledSideEffects ? "true": "false") + "\n";
      std::string set_is_commutable = "SET inst.isCommutable = " + std::string(isCommutable ? "true": "false") + "\n";
      std::string qry = match_inst + set_may_load + set_may_store + set_is_pseudo + set_is_return + set_is_call + set_is_terminator + set_is_branch + set_has_unmodeled_side_effects + set_is_commutable;
      exec_qeury(session, qry.c_str());
  }

  void add_inst_reg(mg_session *session, std::string code, std::string op_name, std::string op_type_str, std::string f_name, std::string bb_name, unsigned bb_id, std::string module_name, int stage, std::string out_reg_name, std::string out_reg_type, std::string out_reg_class, std::string out_reg_size)
  {
      code = sanitize_str(code);

      std::string match_inst = "MATCH (inst:INSTR {session: '" + MemgraphSession + "', stage: " + std::to_string(stage) + ", name: '" + op_name + "', inst: '" + code + "', func_name: '" + f_name + "', basic_block: '" + bb_name + "', bb_id: " + std::to_string(bb_id) + ", module_name: '" + module_name + "', kind: 'instruction', op_type: '" + op_type_str + "'})\n";
      std::string set_name = "SET inst.out_reg_name = '" + out_reg_name + "'\n";
      std::string set_type = "SET inst.out_reg_type = '" + out_reg_type + "'\n";
      std::string set_class = "SET inst.out_reg_class = '" + out_reg_class + "'\n";
      std::string set_size = "SET inst.out_reg_size = '" + out_reg_size + "'\n";
      std::string qry = match_inst + set_name + set_type + set_class + set_size;
      exec_qeury(session, qry.c_str());
  }

  void connect_insts(mg_session *session, std::string src_str, std::string src_op_name, std::string dst_str, std::string dst_op_name, std::string f_name, std::string src_bb_name, std::string dst_bb_name, unsigned src_bb_id, unsigned dst_bb_id, std::string module_name, int stage, std::string rel_type, int op_idx, int out_idx, std::string op_reg_name, std::string op_reg_type, std::string op_reg_class, std::string op_reg_size, bool op_reg_single_use)
  {
      // MERGE: create if not exist else match
      src_str = sanitize_str(src_str);
      dst_str = sanitize_str(dst_str);

      std::string match_src = "MATCH (src_inst:INSTR {session: '" + MemgraphSession + "', stage: " + std::to_string(stage) + ", name: '" + src_op_name + "', inst: '" + src_str + "', func_name: '" + f_name + "', basic_block: '" + src_bb_name + "', bb_id: " + std::to_string(src_bb_id) + ", module_name: '" + module_name + "', kind: 'instruction'})";
      std::string match_dst = "MATCH (dst_inst:INSTR {session: '" + MemgraphSession + "', stage: " + std::to_string(stage) + ", name: '" + dst_op_name + "', inst: '" + dst_str + "', func_name: '" + f_name + "', basic_block: '" + dst_bb_name + "', bb_id: " + std::to_string(dst_bb_id) + ", module_name: '" + module_name + "', kind: 'instruction'})";
      std::string rel = "MERGE (src_inst)-[:" + rel_type + "{op_idx: " + std::to_string(op_idx) +  ", out_idx: " + std::to_string(out_idx) + ", op_reg_name: '" + op_reg_name + "', op_reg_type: '" + op_reg_type + "', op_reg_class: '" + op_reg_class + "', op_reg_size: '" + op_reg_size + "', op_reg_single_use: " + (op_reg_single_use ? "true" : "false") + "}]->(dst_inst);";
      std::string qry = match_src + '\n' + match_dst + '\n' + rel + '\n';
      exec_qeury(session, qry.c_str());
  }



char CDFGPass::ID = 0;
INITIALIZE_PASS_BEGIN(
    CDFGPass, DEBUG_TYPE,
    "Generate CDFG and store in memgraph platform", false,
    false)
INITIALIZE_PASS_DEPENDENCY(TargetPassConfig)
INITIALIZE_PASS_DEPENDENCY(GISelKnownBitsAnalysis)
INITIALIZE_PASS_DEPENDENCY(ProfileSummaryInfoWrapperPass)
INITIALIZE_PASS_DEPENDENCY(LazyBlockFrequencyInfoPass)
INITIALIZE_PASS_END(
    CDFGPass, DEBUG_TYPE,
    "Generate CDFG and store in memgraph platform", false,
    false)

CDFGPass::CDFGPass(CodeGenOptLevel OL, int Stage)
    : MachineFunctionPass(ID), OptLevel(OL), CurrentStage(Stage) {}

// In order not to crash when calling getAnalysis during testing with -run-pass
// we use the default opt level here instead of None, so that the addRequired()
// calls are made in getAnalysisUsage().
CDFGPass::CDFGPass(int Stage)
    : MachineFunctionPass(ID), OptLevel(CodeGenOptLevel::Default), CurrentStage(Stage) {}

void CDFGPass::getAnalysisUsage(AnalysisUsage &AU) const {
  // AU.addRequired<TargetPassConfig>();
  // AU.addRequired<GISelKnownBitsAnalysis>();
  // AU.addPreserved<GISelKnownBitsAnalysis>();
  AU.setPreservesAll();

  // if (OptLevel != CodeGenOptLevel::None) {
  //   AU.addRequired<ProfileSummaryInfoWrapperPass>();
  //   LazyBlockFrequencyInfoPass::getLazyBFIAnalysisUsage(AU);
  // }
  // getSelectionDAGFallbackAnalysisUsage(AU);
  MachineFunctionPass::getAnalysisUsage(AU);
}


bool CDFGPass::runOnMachineFunction(MachineFunction &MF) {

  if (!EnablePass && !FORCE_ENABLE) {
    return true;  // TODO: return false?
  }
  if ((CurrentStage & StageMask) == 0) {
#if DEBUG
    llvm::outs() << "Skipping CDFGPass for stage " << CurrentStage << "." << "\n";
#endif
    return true;  // TODO: return false?
  }
  std::string f_name = MF.getName().str();
  const Module *M = nullptr;
  const llvm::Function *F = nullptr;
  F = &MF.getFunction();
  M = F->getParent();
  // std::string module_name = "moduleABC";
  std::string module_name = M->getName().str();
  if (MF.getProperties().hasProperty(
     MachineFunctionProperties::Property::FailedISel)) {  // check non-gisel?
     llvm::errs() << "skipping CDFGPass in func '" << f_name << "' due to gisel failure" << "\n";
     return true;
  }
  const TargetInstrInfo *TII = MF.getSubtarget().getInstrInfo();  // TODO: move to constructor?
#if DEBUG
  llvm::outs() << "Running CDFGPass on function '" << f_name << "' of module '" << module_name << "'" << "\n";
#endif
  MachineRegisterInfo &MRI = MF.getRegInfo();
  const TargetRegisterInfo *TRI = MF.getSubtarget().getRegisterInfo();
  mg_session *session = connect_to_db(MemgraphHost.c_str(), MemgraphPort);
  if (MemgraphPurge || PURGE_DB){
      auto del = "MATCH (n) DETACH DELETE n;";
      exec_qeury(session, del);
  }
  exec_qeury(session, "CALL schema.assert({}, {}, {}, true) YIELD action, key, keys, label, unique RETURN action, key, keys, label, unique;");
  exec_qeury(session, "CREATE INDEX ON :INSTR");
  exec_qeury(session, "CREATE INDEX ON :INSTR(name)");
  exec_qeury(session, "CREATE INDEX ON :INSTR(inst)");
  exec_qeury(session, "CREATE INDEX ON :INSTR(func_name)");
  exec_qeury(session, "CREATE INDEX ON :INSTR(session)");
  exec_qeury(session, "CREATE INDEX ON :INSTR(stage)");
  exec_qeury(session, "CREATE INDEX ON :BB");
  exec_qeury(session, "CREATE INDEX ON :BB(name)");
  exec_qeury(session, "CREATE INDEX ON :BB(func_name)");
  exec_qeury(session, "CREATE INDEX ON :BB(session)");
  exec_qeury(session, "CREATE INDEX ON :BB(stage)");
  for (MachineBasicBlock &bb : MF) {
    create_bb(session, &bb, f_name, module_name, CurrentStage);
  }
  for (MachineBasicBlock &bb : MF) {
    std::string bb_name = get_bb_name(&bb);
    std::string parent_bb_name = bb_name;
    unsigned bb_id = bb.getBBID()->BaseID;
    unsigned parent_bb_id = bb_id;
#if DEBUG
    // llvm::outs() << "bb_name=" << bb_name << std::endl;
#endif
    for (MachineBasicBlock *suc_bb : successors(&bb)) {
      connect_bbs(session, &bb, suc_bb, f_name, module_name, CurrentStage);
    }
    for (auto LI : bb.liveins()) {
        std::string lir = reg_to_string(LI.PhysReg, TRI);
        // llvm::outs() << "lir=" << lir << std::endl;
        // TODO: LaneMask?
    }
    std::unordered_set<MachineInstr*> forcedOutputs;
    op_type_t op_type = NONE;
    for (MachineInstr &MI : bb) {
      std::string inst_str = llvm_to_string(&MI);
      std::string name = std::string(TII->getName(MI.getOpcode()));
      // llvm::outs() << "name=" << name << "\n";
      if (name == "DBG_VALUE") continue;
      // llvm::outs() << "> " << inst_str << "\n";
      if (MI.isTerminator()) {
        op_type = OUTPUT;
      } else if (name == "PHI" || name == "G_PHI") {
        op_type = INPUT;
        for (const MachineOperand &MO : MI.operands()) {
          if (MO.getType() == MachineOperand::MO_Register) {
            auto Reg = MO.getReg();
            if (Reg.isVirtual()) {
              MachineInstr *MI_ = MRI.getVRegDef(Reg);
              if (!MI_) continue;
              MachineBasicBlock *ParentMBB = MI_->getParent();
              // if (ParentMBB == &bb) {
                forcedOutputs.insert(MI_);
              // }
            }
          }
        }
      } else if (auto iter = forcedOutputs.find(&MI); iter != forcedOutputs.end()) {
        op_type = OUTPUT;
        forcedOutputs.erase(&MI);
      } else if(isOutputForBasicBlock(&MI, &MRI)) {
        op_type = OUTPUT;
      } else {
        op_type = OPERATOR;
      }
      std::string op_type_str = op_type_to_str(op_type);
#if DEBUG
      llvm::outs() << "op_type_str=" << op_type_str << "\n";
#endif
      create_inst(session, inst_str, name, op_type_str, f_name, bb_name, bb_id, module_name, CurrentStage);
      bool mayLoad = MI.mayLoad();
      bool mayStore = MI.mayStore();
      bool isPseudo = MI.isPseudo();
      bool isReturn = MI.isReturn();
      bool isCall = MI.isCall();
      bool isTerminator = MI.isTerminator();
      bool isBranch = MI.isBranch();
      bool hasUnmodeledSideEffects = MI.hasUnmodeledSideEffects();
      bool isCommutable = MI.isCommutable();
      add_inst_preds(session, inst_str, name, op_type_str, f_name, bb_name, bb_id, module_name, CurrentStage, mayLoad, mayStore, isPseudo, isReturn, isCall, isTerminator, isBranch, hasUnmodeledSideEffects, isCommutable);
      std::string out_reg_name = "unknown";
      std::string out_reg_type = "unknown";
      std::string out_reg_class = "unknown";
      std::string out_reg_size = "unknown";
      for (const MachineOperand &MO : MI.defs()) {
        if (MO.isReg()) {
          auto Reg2 = MO.getReg();
          std::string temp;
          raw_string_ostream tmpstream(temp);
          tmpstream << printReg(Reg2, TRI, 0, &MRI);
          out_reg_name = tmpstream.str();
          LLT ty2 = MRI.getType(Reg2);
          std::string temp2;
          raw_string_ostream tmpstream2(temp2);
          tmpstream2 << ty2;
          out_reg_type = tmpstream2.str();
          if (Reg2.isVirtual()) {
            std::string temp3;
            raw_string_ostream tmpstream3(temp3);
            tmpstream3 << printRegClassOrBank(Reg2, MRI, TRI);
            out_reg_class = tmpstream3.str();
          }
          auto reg_size = TRI->getRegSizeInBits(Reg2, MRI);
          std::string temp4;
          raw_string_ostream tmpstream4(temp4);
          reg_size.print(tmpstream4);
          out_reg_size = tmpstream4.str();
          // if (Reg2.isVirtual()) {
          // llvm::outs() << "printRegClassOrBank2=" << printRegClassOrBank(Reg2, MRI, TRI) << "\n";
          // }
        }
        break; // TODO: support multiple out types
      }
      add_inst_reg(session, inst_str, name, op_type_str, f_name, bb_name, bb_id, module_name, CurrentStage, out_reg_name, out_reg_type, out_reg_class, out_reg_size);
      if (MI.getNumOperands() == 0) continue;
#if DEBUG
      llvm::outs() << "instr_str=" << inst_str << "\n";
#endif
      int op_idx = 0;
      int out_idx = -1;  // -1 is unknown (if not a virtual_reg), default to 0?
      // TODO: change to use_idx, def_idx
      for (const MachineOperand &MO : MI.uses()) {
        bool isLabelOp = false;
#if DEBUG
        llvm::outs() << "MO" << "\n";
#endif
        op_type_t op_type_ = NONE;
        std::string src_str = llvm_to_string(&MO);
        std::string src_op_name = "Const";
        std::string src_reg_name = "unknown";
        std::string src_reg_type = "unknown";
        std::string src_reg_class = "unknown";
        std::string src_reg_size = "unknown";
        bool src_reg_single_use = false;

        switch (MO.getType()) {
          case MachineOperand::MO_Register: {
            // llvm::outs() << "=> REG" << "\n";
            auto Reg = MO.getReg();
            src_reg_single_use = true;
            for (MachineRegisterInfo::use_instr_nodbg_iterator I = MRI.use_instr_nodbg_begin(Reg),
                   E = MRI.use_instr_nodbg_end(); I != E; ++I) {
              MachineInstr *UseMI = &*I;
              if (UseMI) {
                // llvm::outs() << "UseMI=" << *UseMI << "\n";
                // src_reg_uses++;
                if (UseMI != &MI) {
                  src_reg_single_use = false;
                  break;
                }
              }
            }
            std::string temp_;
            raw_string_ostream tmpstream_(temp_);
            tmpstream_ << printReg(Reg, TRI, 0, &MRI);
            src_reg_name = tmpstream_.str();
            LLT ty = MRI.getType(Reg);
            std::string temp2_;
            raw_string_ostream tmpstream2_(temp2_);
            tmpstream2_ << ty;
            src_reg_type = tmpstream2_.str();
            if (Reg.isVirtual()) {

                std::string temp;
                raw_string_ostream tmpstream(temp);
                tmpstream << printRegClassOrBank(Reg, MRI, TRI);
                src_reg_class = tmpstream.str();

                auto reg_size = TRI->getRegSizeInBits(Reg, MRI);
                std::string temp2;
                raw_string_ostream tmpstream2(temp2);
                reg_size.print(tmpstream2);
                src_reg_size = tmpstream2.str();

                MachineInstr *MI_ = MRI.getVRegDef(Reg);
                if (!MI_) continue;
                out_idx = MI_->findRegisterDefOperandIdx(Reg, TRI);
                MachineBasicBlock *ParentMBB = MI_->getParent();
                if (ParentMBB != &bb) {
                  op_type_ = INPUT;
                }
                parent_bb_name = get_bb_name(ParentMBB);
                parent_bb_id = ParentMBB->getBBID()->BaseID;
                src_str = llvm_to_string(MI_);
                src_op_name = std::string(TII->getName(MI_->getOpcode()));
                // llvm::outs() << "src_op_name=" << name << "\n";
                // llvm::outs() << ">> " << src_str << "\n";
            } else {
                auto reg_size = TRI->getRegSizeInBits(Reg, MRI);
                std::string temp2;
                raw_string_ostream tmpstream2(temp2);
                reg_size.print(tmpstream2);
                src_reg_size = tmpstream2.str();

                src_str = llvm_to_string(&MO);
                std::string reg_name = reg_to_string(Reg, TRI);
                // src_op_name = "PhysReg";
                src_op_name = reg_name;
                op_type_ = INPUT;
            }
            break;
            // for (MachineInstr &RI : MRI.def_instructions(reg)) {
            //   src_str = llvm_to_string(&RI);
            //   src_op_name = std::string(TII->getName(RI.getOpcode()));
            //   llvm::outs() << "src_op_name=" << name << "\n";
            //   // llvm::outs() << "   " << inst_str;
            //   llvm::outs() << ">> " << src_str << "\n";
            // }
          }
          case MachineOperand::MO_Immediate: {
            // llvm::outs() << "=> IMM" << "\n";
            auto Imm = MO.getImm();
            // llvm::outs() << "Imm=" << Imm << "\n";
            // isConstOp = true;
            op_type_ = CONSTANT;
            break;
          }
          case MachineOperand::MO_CImmediate: {
            // llvm::outs() << "=> CIMM" << "\n";
            auto Imm = MO.getCImm();
            // llvm::outs() << "Imm=" << Imm << "\n";
            // isConstOp = true;
            op_type_ = CONSTANT;
            break;
          }
          case MachineOperand::MO_FPImmediate: {
            // llvm::outs() << "=> FPIMM" << "\n";
            auto Imm = MO.getFPImm();
            // llvm::outs() << "Imm=" << Imm << "\n";
            // isConstOp = true;
            op_type_ = CONSTANT;
            break;
          }
          case MachineOperand::MO_GlobalAddress: {
            llvm::outs() << "=> GA" << "\n";
            isLabelOp = true;
            // op_type_ = CONSTANT;
            break;
          }
          case MachineOperand::MO_MachineBasicBlock: {
            llvm::outs() << "=> MBB" << "\n";
            isLabelOp = true;
            // op_type_ = CONSTANT;
            break;
          }
          case MachineOperand::MO_FrameIndex: {  // TODO: huffbench
            llvm::outs() << "=> FI" << "\n";
            // llvm_unreachable("Not Implemented!");
            isLabelOp = true;
            // op_type_ = CONSTANT;
            break;
          }
          case MachineOperand::MO_ConstantPoolIndex: {
            llvm::outs() << "=> CPI" << "\n";
            // llvm_unreachable("Not Implemented!");
            isLabelOp = true;
            break;
          }
          case MachineOperand::MO_TargetIndex: {
            llvm::outs() << "=> TI" << "\n";
            llvm_unreachable("Not Implemented!");
            break;
          }
          case MachineOperand::MO_JumpTableIndex: {
            llvm::outs() << "=> JTI" << "\n";
            // llvm_unreachable("Not Implemented!");
            isLabelOp = true;
            break;
          }
          case MachineOperand::MO_ExternalSymbol: {
            llvm::outs() << "=> ES" << "\n";
            isLabelOp = true;
            // llvm_unreachable("Not Implemented!");
            break;
          }
          case MachineOperand::MO_BlockAddress: {
            llvm::outs() << "=> BA" << "\n";
            llvm_unreachable("Not Implemented!");
            break;
          }
          case MachineOperand::MO_RegisterMask: {  // TODO: edn, matmult-int, md5sum
            llvm::outs() << "=> RM" << "\n";
            isLabelOp = true;
            // llvm_unreachable("Not Implemented!");
            break;
          }
          case MachineOperand::MO_RegisterLiveOut: {
            llvm::outs() << "=> RLO" << "\n";
            llvm_unreachable("Not Implemented!");
            break;
          }
          case MachineOperand::MO_MCSymbol: {
            llvm::outs() << "=> MCS" << "\n";
            // llvm_unreachable("Not Implemented!");
            isLabelOp = true;  // TODO: add label op_type?
            break;
          }
          case MachineOperand::MO_DbgInstrRef: {
            llvm::outs() << "=> DIR" << "\n";
            llvm_unreachable("Not Implemented!");
            break;
          }
          case MachineOperand::MO_CFIIndex: {
            llvm::outs() << "=> CFII" << "\n";
            llvm_unreachable("Not Implemented!");
            break;
          }
          case MachineOperand::MO_Metadata: {
            // llvm::outs() << "=> MD" << "\n";
            // llvm_unreachable("Not Implemented!");
            continue;
            break;
          }
          case MachineOperand::MO_IntrinsicID: {
            llvm::outs() << "=> IID" << "\n";
            llvm_unreachable("Not Implemented!");
            break;
          }
          case MachineOperand::MO_Predicate: {
            llvm::outs() << "=> PC" << "\n";
            // llvm_unreachable("Not Implemented!");
            isLabelOp = true;
            break;
          }
          case MachineOperand::MO_ShuffleMask: {
            llvm::outs() << "=> SM" << "\n";
            llvm_unreachable("Not Implemented!");
            break;
          }
          default: {
            llvm::outs() << "DEFAULT" << "\n";
            llvm_unreachable("Not Implemented!");
          }
        }
        if (isLabelOp) {
#if DEBUG
          llvm::outs() << "skip label" << "\n";
#endif
          continue;
        }
        // if (src_str == "") src_str = llvm_to_string(&MO);
        // llvm::outs() << "MO=?" << "\n";
        // llvm::outs() << "MO=" << MO << "\n";
        // llvm::outs() << "MO=" << MO << "\n";
        // break;
        // MachineInstr *src_inst = dyn_cast<MachineInstr>(MO);
        // connect_insts(session, src_str, src_op_name, inst_str, name, bb_name, f_name, module_name);
        std::string op_type_str_ = op_type_to_str(op_type_);
#if DEBUG
        llvm::outs() << "op_type_str_=" << op_type_str_ << "\n";
        llvm::outs() << "src_reg_name=" << src_reg_name << "\n";
        llvm::outs() << "src_reg_type=" << src_reg_type << "\n";
        llvm::outs() << "src_reg_class=" << src_reg_class << "\n";
        llvm::outs() << "src_reg_size=" << src_reg_size << "\n";
        llvm::outs() << "src_reg_single_use=" << src_reg_single_use << "\n";
#endif
        bool crossBBMode = false;
        // bool crossBBMode = true;
        if (crossBBMode) {
          if (parent_bb_name != bb_name) {
            connect_insts(session, src_str, src_op_name, inst_str, name, f_name, parent_bb_name, bb_name, parent_bb_id, bb_id, module_name, CurrentStage, "CROSS", op_idx, out_idx, src_reg_name, src_reg_type, src_reg_class, src_reg_size, src_reg_single_use);
          } else {
            connect_insts(session, src_str, src_op_name, inst_str, name, f_name, bb_name, bb_name, bb_id, bb_id, module_name, CurrentStage, "DFG", op_idx, out_idx, src_reg_name, src_reg_type, src_reg_class, src_reg_size, src_reg_single_use);
          }
        } else {
          if (op_type_ == INPUT || op_type_ == CONSTANT) {
            create_inst(session, src_str, src_op_name, op_type_str_, f_name, bb_name, bb_id, module_name, CurrentStage);
            add_inst_reg(session, src_str, src_op_name, op_type_str_, f_name, bb_name, bb_id, module_name, CurrentStage, src_reg_name, src_reg_type, src_reg_class, src_reg_size);
          }
          connect_insts(session, src_str, src_op_name, inst_str, name, f_name, bb_name, bb_name, bb_id, bb_id, module_name, CurrentStage, "DFG", op_idx, out_idx, src_reg_name, src_reg_type, src_reg_class, src_reg_size, src_reg_single_use);
        }
        // if (MO.isReg()) {
        //   auto reg = MO.getReg();
        //   llvm::outs() << "IS REG" << "\n";
        //   // llvm::outs() << "reg=" << reg << "\n";

        // } else {

        // }
        op_idx++;
      }
    }
  }
  return true;
}
