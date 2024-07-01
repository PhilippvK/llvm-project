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
#include "llvm/CodeGen/LowLevelType.h"
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


#define PURGE_DB false
#define FORCE_ENABLE false

#define DEBUG_TYPE "cdfg-pass"

using namespace llvm;

#define CDFG_ENABLE_DEFAULT true

static cl::opt<std::string>
    MemgraphHost("cdfg-memgraph-host", cl::init("localhost"),
                   cl::desc("Hostname of Memgraph server"));
static cl::opt<int>
    MemgraphPort("cdfg-memgraph-port", cl::init(7687),
                   cl::desc("Port of Memgraph server"));
static cl::opt<bool>
    MemgraphPurge("cdfg-memgraph-purge", cl::desc("Purge Memgraph database"));
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
            printf("mgclient version: %s\n", mg_client_version());
#endif

            mg_session_params *params = mg_session_params_make();
            if (!params)
            {
                fprintf(stderr, "failed to allocate session parameters\n");
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
                printf("failed to connect to Memgraph: %s\n", mg_session_error(session));
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
      outs() << "query: " << query << "\n";
      if (mg_session_run(session, query, NULL, NULL, NULL, NULL) < 0)
      {
          outs() << "failed to execute query: " << query << " mg error: " << mg_session_error(session) << "\n";
          mg_session_destroy(session);
          exit(1);
      }
      if (mg_session_pull(session, NULL))
      {
          outs() << "failed to pull results of the query: " << mg_session_error(session) << "\n";
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
          outs() << "error occurred during query execution: " << mg_session_error(session) << "\n";
      }
      else
      {
          printf("query executed successfuly and returned %d rows\n", rows);

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
  void create_bb(mg_session *session, MachineBasicBlock *bb, std::string f_name, std::string module_name)
  {
      std::string store_bb = "MERGE (bb {name: '" + get_bb_name(bb) + "', func_name: '" + f_name + "', module_name: '" + module_name + "', kind: 'basicblock'})";
      std::string set_bb_code = " SET bb.code =  '" + sanitize_str(llvm_to_string(bb)) + "'";
      std::string qry = store_bb + set_bb_code;
      exec_qeury(session, qry.c_str());
  }

  void connect_bbs(mg_session *session, MachineBasicBlock *first_bb, MachineBasicBlock *second_bb, std::string f_name, std::string module_name)
  {
      // MERGE: create if not exist else match
      std::string match_first = "MATCH (first_bb {name: '" + get_bb_name(first_bb) + "', func_name: '" + f_name + "', module_name: '" + module_name + "', kind: 'basicblock'})";
      std::string match_second = "MATCH (second_bb {name: '" + get_bb_name(second_bb) + "', func_name: '" + f_name + "', module_name: '" + module_name + "', kind: 'basicblock'})";
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
  void create_inst(mg_session *session, std::string code, std::string op_name, std::string op_type_str, std::string f_name, std::string bb_name, std::string module_name)
  {
      code = sanitize_str(code);

      std::string store_inst = "MERGE (inst {name: '" + op_name + "', inst: '" + code + "', func_name: '" + f_name + "', basic_block: '" + bb_name + "', module_name: '" + module_name + "', kind: 'instruction', op_type: '" + op_type_str + "'})";
      std::string qry = store_inst + '\n';
      exec_qeury(session, qry.c_str());
  }
  void connect_insts(mg_session *session, std::string src_str, std::string src_op_name, std::string dst_str, std::string dst_op_name, std::string f_name, std::string src_bb_name, std::string dst_bb_name, std::string module_name, std::string rel_type)
  {
      // MERGE: create if not exist else match
      src_str = sanitize_str(src_str);
      dst_str = sanitize_str(dst_str);

      std::string match_src = "MATCH (src_inst {name: '" + src_op_name + "', inst: '" + src_str + "', func_name: '" + f_name + "', basic_block: '" + src_bb_name + "', module_name: '" + module_name + "', kind: 'instruction'})";
      std::string match_dst = "MATCH (dst_inst {name: '" + dst_op_name + "', inst: '" + dst_str + "', func_name: '" + f_name + "', basic_block: '" + dst_bb_name + "', module_name: '" + module_name + "', kind: 'instruction'})";
      std::string rel = "MERGE (src_inst)-[:" + rel_type + "]->(dst_inst);";
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

CDFGPass::CDFGPass(CodeGenOptLevel OL)
    : MachineFunctionPass(ID), OptLevel(OL) {}

// In order not to crash when calling getAnalysis during testing with -run-pass
// we use the default opt level here instead of None, so that the addRequired()
// calls are made in getAnalysisUsage().
CDFGPass::CDFGPass()
    : MachineFunctionPass(ID), OptLevel(CodeGenOptLevel::Default) {}

void CDFGPass::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<TargetPassConfig>();
  AU.addRequired<GISelKnownBitsAnalysis>();
  AU.addPreserved<GISelKnownBitsAnalysis>();

  if (OptLevel != CodeGenOptLevel::None) {
    AU.addRequired<ProfileSummaryInfoWrapperPass>();
    LazyBlockFrequencyInfoPass::getLazyBFIAnalysisUsage(AU);
  }
  getSelectionDAGFallbackAnalysisUsage(AU);
  MachineFunctionPass::getAnalysisUsage(AU);
}


bool CDFGPass::runOnMachineFunction(MachineFunction &MF) {
  if (!EnablePass && !FORCE_ENABLE) {
    return true;
  }
  const TargetInstrInfo *TII = MF.getSubtarget().getInstrInfo();  // TODO: move to constructor?
  llvm::outs() << "CDFGPass" << "\n";
  const Module *M = nullptr;
  const llvm::Function *F = nullptr;
  F = &MF.getFunction();
  M = F->getParent();
  // std::string module_name = "moduleABC";
  std::string module_name = M->getName().str();
  MachineRegisterInfo &MRI = MF.getRegInfo();
  const TargetRegisterInfo *TRI = MF.getSubtarget().getRegisterInfo();
  mg_session *session = connect_to_db(MemgraphHost.c_str(), MemgraphPort);
  if (MemgraphPurge || PURGE_DB){
      auto del = "MATCH (n) DETACH DELETE n;";
      exec_qeury(session, del);
  }
  std::string f_name = MF.getName().str();
  // llvm::outs() << "f_name=" << f_name << std::endl;
  // std::unordered_map<MachineOperand, std::string> op_instr;
  // std::unordered_map<std::string, MachineInstr> op_instr;
  for (MachineBasicBlock &bb : MF) {
    create_bb(session, &bb, f_name, module_name);
  }
  for (MachineBasicBlock &bb : MF) {
    std::string bb_name = get_bb_name(&bb);
    std::string parent_bb_name = bb_name;
    // llvm::outs() << "bb_name=" << bb_name.c_str() << std::endl;
    std::cout << "bb_name=" << bb_name.c_str() << std::endl;
    for (MachineBasicBlock *suc_bb : successors(&bb)) {
      // llvm::outs() << "suc_bb=?" << std::endl;
      // std::cout << "suc_bb=?" << "\n";
      // create_bb(session, suc_bb, f_name, module_name);
      connect_bbs(session, &bb, suc_bb, f_name, module_name);
    }
    for (auto LI : bb.liveins()) {
        std::string lir = reg_to_string(LI.PhysReg, TRI);
        // std::cout << "lir=" << lir << std::endl;
        // TODO: LaneMask?
    }
    std::unordered_set<MachineInstr*> forcedOutputs;
    op_type_t op_type = NONE;
    for (MachineInstr &MI : bb) {
      std::string inst_str = llvm_to_string(&MI);
      std::string name = std::string(TII->getName(MI.getOpcode()));
      std::cout << "name=" << name << "\n";
      if (name == "DBG_VALUE") continue;
      std::cout << "> " << inst_str << "\n";
      if (MI.isTerminator()) {
        op_type = OUTPUT;
      } else if (name == "PHI") {
        op_type = INPUT;
        for (const MachineOperand &MO : MI.operands()) {
          if (MO.getType() == MachineOperand::MO_Register) {
            auto Reg = MO.getReg();
            if (Reg.isVirtual()) {
              MachineInstr *MI_ = MRI.getVRegDef(Reg);
              if (!MI_) continue;
              MachineBasicBlock *ParentMBB = MI_->getParent();
              if (ParentMBB == &bb) {
                forcedOutputs.insert(MI_);
              }
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
      std::cout << "op_type_str=" << op_type_str << "\n";
      create_inst(session, inst_str, name, op_type_str, f_name, bb_name, module_name);
      if (MI.getNumOperands() == 0) continue;
      // llvm::outs() << "   " << inst_str;
      // Instruction::op_iterator opEnd = MI.op_end();
      // for (const MachineOperand &MO : MI.operands()) {
      bool isLabelOp = false;
      // bool isConstOp = false;
      // bool isInputOp = false;
      // break;
      // for (const MachineOperand &MO : llvm::drop_begin(MI.operands())) {
      for (const MachineOperand &MO : MI.uses()) {
        op_type_t op_type_ = NONE;
        std::string src_str = llvm_to_string(&MO);
        std::string src_op_name = "Const";
        switch (MO.getType()) {
          case MachineOperand::MO_Register: {
            std::cout << "=> REG" << "\n";
            auto Reg = MO.getReg();
            // std::cout << "Reg=" << Reg << "\n";
            if (Reg.isVirtual()) {
                MachineInstr *MI_ = MRI.getVRegDef(Reg);
                if (!MI_) continue;
                MachineBasicBlock *ParentMBB = MI_->getParent();
                if (ParentMBB != &bb) {
                  op_type_ = INPUT;
                }
                parent_bb_name = get_bb_name(ParentMBB);
                src_str = llvm_to_string(MI_);
                src_op_name = std::string(TII->getName(MI_->getOpcode()));
                // std::cout << "src_op_name=" << name << "\n";
                // std::cout << ">> " << src_str << "\n";
            } else {
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
            //   std::cout << "src_op_name=" << name << "\n";
            //   // llvm::outs() << "   " << inst_str;
            //   std::cout << ">> " << src_str << "\n";
            // }
          }
          case MachineOperand::MO_Immediate: {
            std::cout << "=> IMM" << "\n";
            auto Imm = MO.getImm();
            // std::cout << "Imm=" << Imm << "\n";
            // isConstOp = true;
            op_type_ = CONSTANT;
            break;
          }
          case MachineOperand::MO_CImmediate: {
            std::cout << "=> CIMM" << "\n";
            auto Imm = MO.getCImm();
            // std::cout << "Imm=" << Imm << "\n";
            // isConstOp = true;
            op_type_ = CONSTANT;
            break;
          }
          case MachineOperand::MO_FPImmediate: {
            std::cout << "=> FPIMM" << "\n";
            auto Imm = MO.getFPImm();
            // std::cout << "Imm=" << Imm << "\n";
            // isConstOp = true;
            op_type_ = CONSTANT;
            break;
          }
          case MachineOperand::MO_GlobalAddress: {
            std::cout << "=> GA" << "\n";
            isLabelOp = true;
            // op_type_ = CONSTANT;
            break;
          }
          case MachineOperand::MO_MachineBasicBlock: {
            std::cout << "=> MBB" << "\n";
            isLabelOp = true;
            // op_type_ = CONSTANT;
            break;
          }
          case MachineOperand::MO_FrameIndex: {  // TODO: huffbench
            std::cout << "=> FI" << "\n";
            // llvm_unreachable("Not Implemented!");
            isLabelOp = true;
            // op_type_ = CONSTANT;
            break;
          }
          case MachineOperand::MO_ConstantPoolIndex: {
            std::cout << "=> CPI" << "\n";
            // llvm_unreachable("Not Implemented!");
            isLabelOp = true;
            break;
          }
          case MachineOperand::MO_TargetIndex: {
            std::cout << "=> TI" << "\n";
            llvm_unreachable("Not Implemented!");
            break;
          }
          case MachineOperand::MO_JumpTableIndex: {
            std::cout << "=> JTI" << "\n";
            // llvm_unreachable("Not Implemented!");
            isLabelOp = true;
            break;
          }
          case MachineOperand::MO_ExternalSymbol: {
            std::cout << "=> ES" << "\n";
            isLabelOp = true;
            // llvm_unreachable("Not Implemented!");
            break;
          }
          case MachineOperand::MO_BlockAddress: {
            std::cout << "=> BA" << "\n";
            llvm_unreachable("Not Implemented!");
            break;
          }
          case MachineOperand::MO_RegisterMask: {  // TODO: edn, matmult-int, md5sum
            std::cout << "=> RM" << "\n";
            isLabelOp = true;
            // llvm_unreachable("Not Implemented!");
            break;
          }
          case MachineOperand::MO_RegisterLiveOut: {
            std::cout << "=> RLO" << "\n";
            llvm_unreachable("Not Implemented!");
            break;
          }
          case MachineOperand::MO_MCSymbol: {
            std::cout << "=> MCS" << "\n";
            llvm_unreachable("Not Implemented!");
            break;
          }
          case MachineOperand::MO_DbgInstrRef: {
            std::cout << "=> DIR" << "\n";
            llvm_unreachable("Not Implemented!");
            break;
          }
          case MachineOperand::MO_CFIIndex: {
            std::cout << "=> CFII" << "\n";
            llvm_unreachable("Not Implemented!");
            break;
          }
          case MachineOperand::MO_Metadata: {
            std::cout << "=> MD" << "\n";
            // llvm_unreachable("Not Implemented!");
            continue;
            break;
          }
          case MachineOperand::MO_IntrinsicID: {
            std::cout << "=> IID" << "\n";
            llvm_unreachable("Not Implemented!");
            break;
          }
          case MachineOperand::MO_Predicate: {
            std::cout << "=> PC" << "\n";
            // llvm_unreachable("Not Implemented!");
            isLabelOp = true;
            break;
          }
          case MachineOperand::MO_ShuffleMask: {
            std::cout << "=> SM" << "\n";
            llvm_unreachable("Not Implemented!");
            break;
          }
          default: {
            std::cout << "DEFAULT" << "\n";
            llvm_unreachable("Not Implemented!");
          }
        }
        if (isLabelOp) {
          continue;
        }
        // if (src_str == "") src_str = llvm_to_string(&MO);
        // std::cout << "MO=?" << "\n";
        // std::cout << "MO=" << MO << "\n";
        // llvm::outs() << "MO=" << MO << "\n";
        // break;
        // MachineInstr *src_inst = dyn_cast<MachineInstr>(MO);
        // connect_insts(session, src_str, src_op_name, inst_str, name, bb_name, f_name, module_name);
        std::string op_type_str_ = op_type_to_str(op_type_);
        std::cout << "op_type_str_=" << op_type_str_ << "\n";
        bool crossBBMode = false;
        // bool crossBBMode = true;
        if (crossBBMode) {
          if (parent_bb_name != bb_name) {
            connect_insts(session, src_str, src_op_name, inst_str, name, f_name, parent_bb_name, bb_name, module_name, "CROSS");
          } else {
            connect_insts(session, src_str, src_op_name, inst_str, name, f_name, bb_name, bb_name, module_name, "DFG");
          }
        } else {
          if (op_type_ == INPUT || op_type_ == CONSTANT) {
            create_inst(session, src_str, src_op_name, op_type_str_, f_name, bb_name, module_name);
          }
          connect_insts(session, src_str, src_op_name, inst_str, name, f_name, bb_name, bb_name, module_name, "DFG");
        }
        // if (MO.isReg()) {
        //   auto reg = MO.getReg();
        //   std::cout << "IS REG" << "\n";
        //   // std::cout << "reg=" << reg << "\n";

        // } else {

        // }
      }
    }
  }
  return true;
}
