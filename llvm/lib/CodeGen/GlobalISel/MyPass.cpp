//===- llvm/CodeGen/GlobalISel/PatternGen.cpp - PatternGen ---==//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
/// \file
/// This file implements the PatternGen class.
//===----------------------------------------------------------------------===//

#include <iostream>
#include <mgclient.h>

#include "llvm/CodeGen/GlobalISel/MyPass.h"
// #include "../../../tools/pattern-gen/lib/InstrInfo.hpp"
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


// #define PURGE_DB true
#define PURGE_DB false

#define DEBUG_TYPE "my-pass"

using namespace llvm;

#ifdef LLVM_GISEL_COV_PREFIX
static cl::opt<std::string>
    CoveragePrefix("gisel-coverage-prefix", cl::init(LLVM_GISEL_COV_PREFIX),
                   cl::desc("Record GlobalISel rule coverage files of this "
                            "prefix if instrumentation was generated"));
#else
static const std::string CoveragePrefix;
#endif

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

  void connect_bbs(mg_session *session, MachineBasicBlock *first_bb, MachineBasicBlock *second_bb, std::string f_name, std::string module_name)
  {
      // MERGE: create if not exist else match
      std::string store_first = "MERGE (first_bb {name: '" + get_bb_name(first_bb) + "', func_name: '" + f_name + "', module_name: '" + module_name + "'})";
      std::string set_frist_code = " SET first_bb.code =  '" + sanitize_str(llvm_to_string(first_bb)) + "'";
      std::string store_second = " MERGE (second_bb {name: '" + get_bb_name(second_bb) + "', func_name: '" + f_name + "', module_name: '" + module_name + "'})";
      std::string set_second_code = " SET second_bb.code =  '" + sanitize_str(llvm_to_string(second_bb)) + "'";
      std::string rel = " MERGE (first_bb)-[:CFG]->(second_bb);";
      std::string qry = store_first + set_frist_code + store_second + set_second_code + rel;
      exec_qeury(session, qry.c_str());
  }


  void connect_insts(mg_session *session, std::string src_str, std::string src_op_name, std::string dst_str, std::string dst_op_name, std::string f_name, std::string module_name)
  {
      // MERGE: create if not exist else match
      src_str = sanitize_str(src_str);
      dst_str = sanitize_str(dst_str);

      std::string store_src = "MERGE (src_inst {name: '" + src_op_name + "', inst: '" + src_str + "', func_name: '" + f_name + "', module_name: '" + module_name + "'})";
      std::string store_dst = "MERGE (dst_inst {name: '" + dst_op_name + "', inst: '" + dst_str + "', func_name: '" + f_name + "', module_name: '" + module_name + "'})";
      std::string rel = "MERGE (src_inst)-[:DFG]->(dst_inst);";
      std::string qry = store_src + '\n' + store_dst + '\n' + rel + '\n';
      exec_qeury(session, qry.c_str());
  }



// std::ostream *PatternGenArgs::OutStream = nullptr;
// std::vector<CDSLInstr> const *PatternGenArgs::Instrs = nullptr;
// PGArgsStruct PatternGenArgs::Args;
//
// struct PatternArg {
//   std::string ArgTypeStr;
//   LLT Llt;
//   // We also have in and out bits in the CDSLInstr struct itself.
//   // These bits are currently ignored though. Instead, we find inputs
//   // and outputs during pattern gen and store that in these fields.
//   // We may want to add a warning on mismatch between the two.
//   bool In;
//   bool Out;
// };
//
// static CDSLInstr const *CurInstr = nullptr;
// static SmallVector<PatternArg, 8> PatternArgs;

char MyPass::ID = 0;
INITIALIZE_PASS_BEGIN(
    MyPass, DEBUG_TYPE,
    "Convert instruction behavior functions to TableGen ISel patterns", false,
    false)
INITIALIZE_PASS_DEPENDENCY(TargetPassConfig)
INITIALIZE_PASS_DEPENDENCY(GISelKnownBitsAnalysis)
INITIALIZE_PASS_DEPENDENCY(ProfileSummaryInfoWrapperPass)
INITIALIZE_PASS_DEPENDENCY(LazyBlockFrequencyInfoPass)
INITIALIZE_PASS_END(
    MyPass, DEBUG_TYPE,
    "Convert instruction behavior functions to TableGen ISel patterns", false,
    false)

MyPass::MyPass(CodeGenOptLevel OL)
    : MachineFunctionPass(ID), OptLevel(OL) {}

// In order not to crash when calling getAnalysis during testing with -run-pass
// we use the default opt level here instead of None, so that the addRequired()
// calls are made in getAnalysisUsage().
MyPass::MyPass()
    : MachineFunctionPass(ID), OptLevel(CodeGenOptLevel::Default) {}

void MyPass::getAnalysisUsage(AnalysisUsage &AU) const {
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

// enum PatternErrorT {
//   SUCCESS = 0,
//   MULTIPLE_BLOCKS,
//   FORMAT_RETURN,
//   FORMAT_STORE,
//   FORMAT_LOAD,
//   FORMAT_IMM,
//   FORMAT
// };
// struct PatternError {
//   PatternErrorT Type;
//   MachineInstr *Inst;
//   PatternError(PatternErrorT Type) : Type(Type), Inst(nullptr) {}
//   PatternError(PatternErrorT Type, MachineInstr *Inst)
//       : Type(Type), Inst(Inst) {}
//   operator bool() const { return Type != 0; }
// };
//
// std::string Errors[] = {"success",        "multiple blocks", "expected return",
//                         "expected store", "load format",     "immediate format",
//                         "format"};
//
// static const std::unordered_map<unsigned, std::string> cmpStr = {
//     {CmpInst::Predicate::ICMP_EQ, "SETEQ"},
//     {CmpInst::Predicate::ICMP_NE, "SETNE"},
//     {CmpInst::Predicate::ICMP_SLT, "SETLT"},
//     {CmpInst::Predicate::ICMP_SLE, "SETLE"},
//     {CmpInst::Predicate::ICMP_SGT, "SETGT"},
//     {CmpInst::Predicate::ICMP_SGE, "SETGE"},
//     {CmpInst::Predicate::ICMP_ULT, "SETULT"},
//     {CmpInst::Predicate::ICMP_ULE, "SETULE"},
//     {CmpInst::Predicate::ICMP_UGT, "SETUGT"},
//     {CmpInst::Predicate::ICMP_UGE, "SETUGE"},
// };
//
// std::string lltToString(LLT Llt) {
//   if (Llt.isFixedVector())
//     return "v" + std::to_string(Llt.getElementCount().getFixedValue()) + lltToString(Llt.getElementType());
//   if (Llt.isScalar())
//     return "i" + std::to_string(Llt.getSizeInBits());
//   assert(0 && "invalid type");
// }
//
// std::string lltToRegTypeStr(LLT Type) {
//   if (Type.isValid()) {
//     if (Type.isFixedVector() && Type.getElementType().isScalar() &&
//         Type.getSizeInBits() == 32) {
//       if (Type.getElementType().getSizeInBits() == 8)
//         return "GPR32V4";
//       if (Type.getElementType().getSizeInBits() == 16)
//         return "GPR32V2";
//       abort();
//     } else
//       return "GPR";
//   }
//   assert(0 && "invalid type");
// }
//
// std::string makeImmTypeStr(int Size, bool Signed) {
//   return (Signed ? "simm" : "uimm") + std::to_string(Size);
// }
//
// struct PatternNode {
//   enum PatternNodeKind {
//     PN_NOp,
//     PN_Binop,
//     PN_Ternop,
//     PN_Shuffle,
//     PN_Compare,
//     PN_Unop,
//     PN_Constant,
//     PN_Register,
//     PN_Select,
//   };
//
// private:
//   const PatternNodeKind kind;
//
// public:
//   PatternNodeKind getKind() const { return kind; }
//   LLT Type;
//   PatternNode(PatternNodeKind Kind, LLT Type) : kind(Kind), Type(Type) {}
//
//   virtual std::string patternString(int Indent = 0) = 0;
//   virtual LLT getRegisterTy(int OperandId) const {
//     if (OperandId == -1)
//       return Type;
//     return LLT(MVT::INVALID_SIMPLE_VALUE_TYPE);
//   }
//   virtual ~PatternNode() {}
// };
//
// struct NOpNode : public PatternNode {
//   int Op;
//   std::vector<std::unique_ptr<PatternNode>> Operands;
//   NOpNode(LLT Type, int Op, std::vector<std::unique_ptr<PatternNode>> Operands)
//       : PatternNode(PN_NOp, Type), Op(Op), Operands(std::move(Operands)) {}
//
//   std::string patternString(int Indent = 0) override {
//     static const std::unordered_map<int, std::string> NOpStr = {
//         {TargetOpcode::G_BUILD_VECTOR, "build_vector"},
//         {TargetOpcode::G_SELECT, "vselect"}};
//
//     std::string S = "(" + std::string(NOpStr.at(Op)) + " ";
//     for (auto &Operand : Operands)
//       S += Operand->patternString(Indent + 1) + ", ";
//     if (!Operands.empty())
//       S = S.substr(0, S.size() - 2);
//
//     S += ")";
//     return S;
//   }
//   LLT getRegisterTy(int OperandId) const override {
//     if (OperandId == -1)
//       return Type;
//
//     for (auto &Operand : Operands) {
//       auto T = Operand->getRegisterTy(OperandId);
//       if (T.isValid())
//         return T;
//     }
//     return LLT(MVT::INVALID_SIMPLE_VALUE_TYPE);
//   }
//   static bool classof(const PatternNode *P) { return P->getKind() == PN_NOp; }
// };
//
// struct ShuffleNode : public PatternNode {
//   int Op;
//   std::unique_ptr<PatternNode> First;
//   std::unique_ptr<PatternNode> Second;
//   // std::unique_ptr<ArrayRef<int>> Mask;
//   ArrayRef<int> Mask;
//
//   ShuffleNode(LLT Type, int Op, std::unique_ptr<PatternNode> First,
//             std::unique_ptr<PatternNode> Second, ArrayRef<int> Mask)
//             // std::unique_ptr<PatternNode> Second, std::unique_ptr<ArrayRef<int>> Mask)
//       : PatternNode(PN_Shuffle, Type), Op(Op), First(std::move(First)),
//         Second(std::move(Second)), Mask(std::move(Mask)) {}
//
//   std::string patternString(int Indent = 0) override {
//     std::string TypeStr = lltToString(Type);
//     std::string MaskStr = "";
//
//     for (size_t i = 0; i < Mask.size(); i++) {
//       if (i != 0) {
//         MaskStr += ", ";
//       }
//       MaskStr += std::to_string(Mask[i]);
//     }
//     std::string OpString = "(vector_shuffle<" + MaskStr + "> " + First->patternString(Indent + 1) + ", " + Second->patternString(Indent + 1) + ")";
//
//     // Explicitly specifying types for all ops increases pattern compile time
//     // significantly, so we only do for ops where deduction fails otherwise.
//     bool PrintType = false;
//
//     if (PrintType)
//       return "(" + TypeStr + " " + OpString + ")";
//     return OpString;
//   }
//
//   LLT getRegisterTy(int OperandId) const override {
//     if (OperandId == -1)
//       return Type;
//
//     auto FirstT = First->getRegisterTy(OperandId);
//     auto SecondT = Second->getRegisterTy(OperandId);
//     // auto ThirdT = Third->getRegisterTy(OperandId);
//     return FirstT.isValid() ? FirstT : SecondT;
//   }
//
//   static bool classof(const PatternNode *p) { return p->getKind() == PN_Shuffle; }
// };
//
// struct TernopNode : public PatternNode {
//   int Op;
//   std::unique_ptr<PatternNode> First;
//   std::unique_ptr<PatternNode> Second;
//   std::unique_ptr<PatternNode> Third;
//
//   TernopNode(LLT Type, int Op, std::unique_ptr<PatternNode> First,
//             std::unique_ptr<PatternNode> Second, std::unique_ptr<PatternNode> Third)
//       : PatternNode(PN_Ternop, Type), Op(Op), First(std::move(First)),
//         Second(std::move(Second)), Third(std::move(Third)) {}
//
//   std::string patternString(int Indent = 0) override {
//     static const std::unordered_map<int, std::string> BinopStr = {
//         {TargetOpcode::G_INSERT_VECTOR_ELT, "vector_insert"},
//         {TargetOpcode::G_SELECT, "select"}};
//
//     std::string TypeStr = lltToString(Type);
//     std::string OpString = "(" + std::string(BinopStr.at(Op)) + " " +
//                            First->patternString(Indent + 1) + ", " +
//                            Second->patternString(Indent + 1) + ", " +
//                            Third->patternString(Indent + 1) + ")";
//
//     // Explicitly specifying types for all ops increases pattern compile time
//     // significantly, so we only do for ops where deduction fails otherwise.
//     bool PrintType = false;
//
//     if (PrintType)
//       return "(" + TypeStr + " " + OpString + ")";
//     return OpString;
//   }
//
//   LLT getRegisterTy(int OperandId) const override {
//     if (OperandId == -1)
//       return Type;
//
//     auto FirstT = First->getRegisterTy(OperandId);
//     auto SecondT = Second->getRegisterTy(OperandId);
//     auto ThirdT = Third->getRegisterTy(OperandId);
//     return FirstT.isValid() ? FirstT : (SecondT.isValid() ? SecondT : ThirdT);
//   }
//
//   static bool classof(const PatternNode *p) { return p->getKind() == PN_Ternop; }
// };
//
// struct BinopNode : public PatternNode {
//   int Op;
//   std::unique_ptr<PatternNode> Left;
//   std::unique_ptr<PatternNode> Right;
//
//   BinopNode(LLT Type, int Op, std::unique_ptr<PatternNode> Left,
//             std::unique_ptr<PatternNode> Right)
//       : PatternNode(PN_Binop, Type), Op(Op), Left(std::move(Left)),
//         Right(std::move(Right)) {}
//
//   std::string patternString(int Indent = 0) override {
//     static const std::unordered_map<int, std::string> BinopStr = {
//         {TargetOpcode::G_ADD, "add"},
//         {TargetOpcode::G_PTR_ADD, "add"},
//         {TargetOpcode::G_SUB, "sub"},
//         {TargetOpcode::G_MUL, "mul"},
//         {TargetOpcode::G_SDIV, "div"},
//         {TargetOpcode::G_AND, "and"},
//         {TargetOpcode::G_OR, "or"},
//         {TargetOpcode::G_XOR, "xor"},
//         {TargetOpcode::G_SHL, "shl"},
//         {TargetOpcode::G_LSHR, "srl"},
//         {TargetOpcode::G_ASHR, "sra"},
//         {TargetOpcode::G_SMAX, "smax"},
//         {TargetOpcode::G_UMAX, "umax"},
//         {TargetOpcode::G_SMIN, "smin"},
//         {TargetOpcode::G_UMIN, "umin"},
//         {TargetOpcode::G_EXTRACT_VECTOR_ELT, "vector_extract"}};
//
//     std::string TypeStr = lltToString(Type);
//     std::string OpString = "(" + std::string(BinopStr.at(Op)) + " " +
//                            Left->patternString(Indent + 1) + ", " +
//                            Right->patternString(Indent + 1) + ")";
//
//     // Explicitly specifying types for all ops increases pattern compile time
//     // significantly, so we only do for ops where deduction fails otherwise.
//     bool PrintType = false;
//     switch (Op) {
//     case TargetOpcode::G_SHL:
//     case TargetOpcode::G_LSHR:
//     case TargetOpcode::G_ASHR:
//       PrintType = true;
//       break;
//     default:
//       break;
//     }
//
//     if (PrintType)
//       return "(" + TypeStr + " " + OpString + ")";
//     return OpString;
//   }
//
//   LLT getRegisterTy(int OperandId) const override {
//     if (OperandId == -1)
//       return Type;
//
//     auto LeftT = Left->getRegisterTy(OperandId);
//     return LeftT.isValid() ? LeftT : Right->getRegisterTy(OperandId);
//   }
//
//   static bool classof(const PatternNode *p) { return p->getKind() == PN_Binop; }
// };
//
// struct CompareNode : public BinopNode {
//   CmpInst::Predicate Cond;
//
//   CompareNode(LLT Type, CmpInst::Predicate Cond,
//               std::unique_ptr<PatternNode> Left,
//               std::unique_ptr<PatternNode> Right)
//       : BinopNode(Type, ISD::SETCC, std::move(Left), std::move(Right)),
//         Cond(Cond) {}
//
//   std::string patternString(int Indent = 0) override {
//     std::string TypeStr = lltToString(Type);
//     std::string LhsTypeStr = lltToString(Left->Type);
//     std::string RhsTypeStr = lltToString(Right->Type);
//
//     return "(" + TypeStr + " (setcc (" + LhsTypeStr + " "+ Left->patternString(Indent + 1) + "), (" + RhsTypeStr + " " +
//            Right->patternString(Indent + 1) + "), " + cmpStr.at(Cond) + "))";
//   }
// };
//
// struct SelectNode : public PatternNode {
//   ISD::CondCode Cond;
//   std::unique_ptr<PatternNode> Left;
//   std::unique_ptr<PatternNode> Right;
//   std::unique_ptr<PatternNode> Tval;
//   std::unique_ptr<PatternNode> Fval;
//
//   SelectNode(LLT Type, ISD::CondCode Cond, std::unique_ptr<PatternNode> Left,
//              std::unique_ptr<PatternNode> Right,
//              std::unique_ptr<PatternNode> Tval,
//              std::unique_ptr<PatternNode> Fval)
//       : PatternNode(PN_Select, Type), Cond(Cond), Left(std::move(Left)),
//         Right(std::move(Right)), Tval(std::move(Tval)), Fval(std::move(Fval)) {}
//
//   std::string patternString(int Indent = 0) override {
//     std::string TypeStr = lltToString(Type);
//
//     return "(" + TypeStr + " (riscv_selectcc " +
//            Left->patternString(Indent + 1) + ", " +
//            Right->patternString(Indent + 1) + ", " + cmpStr.at(Cond) + ", " +
//            Tval->patternString(Indent + 1) + ", " +
//            Fval->patternString(Indent + 1) + "))";
//   }
//
//   LLT getRegisterTy(int OperandId) const override {
//     if (OperandId == -1)
//       return Type;
//
//     for (auto *Operand : {&Left, &Right, &Tval, &Fval}) {
//       auto T = (*Operand)->getRegisterTy(OperandId);
//       if (T.isValid())
//         return T;
//     }
//     return LLT(MVT::INVALID_SIMPLE_VALUE_TYPE);
//   }
//
//   static bool classof(const PatternNode *p) {
//     return p->getKind() == PN_Select;
//   }
// };
//
// struct UnopNode : public PatternNode {
//   int Op;
//   std::unique_ptr<PatternNode> Operand;
//
//   UnopNode(LLT Type, int Op, std::unique_ptr<PatternNode> Operand)
//       : PatternNode(PN_Unop, Type), Op(Op), Operand(std::move(Operand)) {}
//
//   std::string patternString(int Indent = 0) override {
//     static const std::unordered_map<int, std::string> UnopStr = {
//         {TargetOpcode::G_SEXT, "sext"},
//         {TargetOpcode::G_ZEXT, "zext"},
//         {TargetOpcode::G_VECREDUCE_ADD, "vecreduce_add"},
//         {TargetOpcode::G_TRUNC, "trunc"},
//         {TargetOpcode::G_BITCAST, "bitcast"},
//         {TargetOpcode::G_ABS, "abs"}};
//
//     std::string TypeStr = lltToString(Type);
//
//     // ignore bitcast ops for now
//     if (Op == TargetOpcode::G_BITCAST)
//       return Operand->patternString(Indent);
//
//     return "(" + TypeStr + " (" + std::string(UnopStr.at(Op)) + " " +
//            Operand->patternString(Indent + 1) + "))";
//   }
//
//   LLT getRegisterTy(int OperandId) const override {
//     if (OperandId == -1 && Op != TargetOpcode::G_BITCAST)
//       return Type;
//     return Operand->getRegisterTy(OperandId);
//   }
//
//   static bool classof(const PatternNode *p) { return p->getKind() == PN_Unop; }
// };
//
// struct ConstantNode : public PatternNode {
//   uint32_t Constant;
//   ConstantNode(LLT Type, uint32_t c)
//       : PatternNode(PN_Constant, Type), Constant(c) {}
//
//   std::string patternString(int Indent = 0) override {
//     if (Type.isFixedVector()) {
//       std::string TypeStr = lltToString(Type);
//       return "(" + TypeStr + " (i32 " + std::to_string((int)Constant) + "))";
//     } else {
//       return "(i32 " + std::to_string((int)Constant) + ")";
//     }
//   }
//
//   static bool classof(const PatternNode *p) {
//     return p->getKind() == PN_Constant;
//   }
// };
//
// struct RegisterNode : public PatternNode {
//
//   bool IsImm;
//   StringRef Name;
//
//   int Offset;
//   int Size;
//   bool Sext;
//   bool VectorExtract =
//       false; // TODO: set based on type of this register in other uses
//
//   size_t RegIdx;
//
//   RegisterNode(LLT Type, StringRef Name, size_t RegIdx, bool IsImm, int Offset,
//                int Size, bool Sext)
//       : PatternNode(PN_Register, Type), IsImm(IsImm), Name(Name),
//         Offset(Offset), Size(Size), Sext(Sext), RegIdx(RegIdx) {}
//
//   std::string patternString(int Indent = 0) override {
//
//     if (IsImm) {
//       // Immediate Operands
//       assert(Offset == 0 && "immediates must have offset 0");
//       return std::string("(i32 ") + (Sext ? "simm" : "uimm") +
//              std::to_string(Size) + ":$" + std::string(Name) + ")";
//     }
//
//     // Full-Size Register Operands
//     if (Size == 32) {
//       if (Type.isScalar() && Type.getSizeInBits() == 32)
//         return "GPR:$" + std::string(Name);
//       if (Type.isFixedVector() && Type.getSizeInBits() == 32 &&
//           Type.getElementType().isScalar() &&
//           Type.getElementType().getSizeInBits() == 8)
//         return "GPR32V4:$" + std::string(Name);
//       if (Type.isFixedVector() && Type.getSizeInBits() == 32 &&
//           Type.getElementType().isScalar() &&
//           Type.getElementType().getSizeInBits() == 16)
//         return "GPR32V2:$" + std::string(Name);
//       abort();
//     }
//
//     // Sub-Register Operands
//     if (Size == 16 || Size == 8) {
//       std::string Str;
//       if (VectorExtract) {
//         Str = std::string("(i32 (vector_extract GPR32V") +
//               ((Size == 16) ? "2" : "4") + ":$" + std::string(Name) + ", " +
//               std::to_string((Size == 16) ? (Offset / 2) : (Offset)) + "))";
//       } else {
//         if (Offset == 0)
//           Str = "GPR:$" + std::string(Name);
//         else
//           Str = "(i32 (srl GPR:$" + std::string(Name) + ", (i32 " +
//                 std::to_string(Offset * 8) + ")))";
//       }
//       return Str;
//     }
//     abort();
//   }
//
//   static bool classof(const PatternNode *p) {
//     return p->getKind() == PN_Register;
//   }
// };
//
// static std::pair<PatternError, std::unique_ptr<PatternNode>>
// traverse(MachineRegisterInfo &MRI, MachineInstr &Cur);
//
// static std::pair<PatternError, std::unique_ptr<PatternNode>>
// traverseOperand(MachineRegisterInfo &MRI, MachineInstr &Cur, int i) {
//   assert(Cur.getOperand(1).isReg() && "expected register");
//   auto *Op = MRI.getOneDef(Cur.getOperand(1).getReg());
//   if (!Op)
//     return std::make_pair(FORMAT, nullptr);
//   auto [Err, Node] = traverse(MRI, *Op->getParent());
//   if (Err)
//     return std::make_pair(Err, nullptr);
//
//   return std::make_pair(SUCCESS, std::move(Node));
// }
//
// static std::tuple<PatternError, std::unique_ptr<PatternNode>,
//                   std::unique_ptr<PatternNode>, std::unique_ptr<PatternNode>>
// traverseTernopOperands(MachineRegisterInfo &MRI, MachineInstr &Cur,
//                       int start = 1) {
//   assert(Cur.getOperand(start).isReg() && "expected register");
//   auto *First = MRI.getOneDef(Cur.getOperand(start).getReg());
//   if (!First)
//     return std::make_tuple(PatternError(FORMAT, &Cur), nullptr, nullptr, nullptr);
//   assert(Cur.getOperand(start + 1).isReg() && "expected register");
//   auto *Second = MRI.getOneDef(Cur.getOperand(start + 1).getReg());
//   if (!Second)
//     return std::make_tuple(PatternError(FORMAT, &Cur), nullptr, nullptr, nullptr);
//   assert(Cur.getOperand(start + 2).isReg() && "expected register");
//   auto *Third = MRI.getOneDef(Cur.getOperand(start + 2).getReg());
//   if (!Third)
//     return std::make_tuple(PatternError(FORMAT, &Cur), nullptr, nullptr, nullptr);
//
//   auto [ErrFirst, NodeFirst] = traverse(MRI, *First->getParent());
//   if (ErrFirst)
//     return std::make_tuple(ErrFirst, nullptr, nullptr, nullptr);
//
//   auto [ErrSecond, NodeSecond] = traverse(MRI, *Second->getParent());
//   if (ErrSecond)
//     return std::make_tuple(ErrSecond, nullptr, nullptr, nullptr);
//
//   auto [ErrThird, NodeThird] = traverse(MRI, *Third->getParent());
//   if (ErrThird)
//     return std::make_tuple(ErrThird, nullptr, nullptr, nullptr);
//
//   return std::make_tuple(SUCCESS, std::move(NodeFirst), std::move(NodeSecond), std::move(NodeThird));
// }
//
// static std::tuple<PatternError, std::unique_ptr<PatternNode>,
//                   std::unique_ptr<PatternNode>>
// traverseBinopOperands(MachineRegisterInfo &MRI, MachineInstr &Cur,
//                       int start = 1) {
//   assert(Cur.getOperand(start).isReg() && "expected register");
//   auto *LHS = MRI.getOneDef(Cur.getOperand(start).getReg());
//   if (!LHS)
//     return std::make_tuple(PatternError(FORMAT, &Cur), nullptr, nullptr);
//   assert(Cur.getOperand(start + 1).isReg() && "expected register");
//   auto *RHS = MRI.getOneDef(Cur.getOperand(start + 1).getReg());
//   if (!RHS)
//     return std::make_tuple(PatternError(FORMAT, &Cur), nullptr, nullptr);
//
//   auto [ErrL, NodeL] = traverse(MRI, *LHS->getParent());
//   if (ErrL)
//     return std::make_tuple(ErrL, nullptr, nullptr);
//
//   auto [ErrR, NodeR] = traverse(MRI, *RHS->getParent());
//   if (ErrR)
//     return std::make_tuple(ErrR, nullptr, nullptr);
//   return std::make_tuple(SUCCESS, std::move(NodeL), std::move(NodeR));
// }
//
// static std::tuple<PatternError, std::unique_ptr<PatternNode>>
// traverseUnopOperands(MachineRegisterInfo &MRI, MachineInstr &Cur,
//                       int start = 1) {
//   assert(Cur.getOperand(start).isReg() && "expected register");
//   auto *RHS = MRI.getOneDef(Cur.getOperand(start).getReg());
//   if (!RHS)
//     return std::make_tuple(PatternError(FORMAT, &Cur), nullptr);
//
//   auto [ErrR, NodeR] = traverse(MRI, *RHS->getParent());
//   if (ErrR)
//     return std::make_tuple(ErrR, nullptr);
//   return std::make_tuple(SUCCESS, std::move(NodeR));
// }
//
// static std::tuple<PatternError, std::vector<std::unique_ptr<PatternNode>>>
// traverseNOpOperands(MachineRegisterInfo &MRI, MachineInstr &Cur, size_t N,
//                       int start = 1) {
//   std::vector<std::unique_ptr<PatternNode>> operands(N);
//   for (size_t i = 0; i < N; i++) {
//       assert(Cur.getOperand(start + i).isReg() && "expected register");
//       auto *Node = MRI.getOneDef(Cur.getOperand(start + i).getReg());
//       if (!Node) {
//         return std::make_tuple(PatternError(FORMAT, &Cur), std::vector<std::unique_ptr<PatternNode>>());
//       }
//
//       auto [Err_, Node_] = traverse(MRI, *Node->getParent());
//       if (Err_) {
//         return std::make_tuple(Err_, std::vector<std::unique_ptr<PatternNode>>());
//       }
//       // return std::make_tuple(SUCCESS, std::move(NodeR));
//       operands[i] = std::move(Node_);
//   }
//   return std::make_tuple(SUCCESS, std::move(operands));
// }
//
// static int getArgIdx(MachineRegisterInfo &MRI, Register Reg) {
//   auto It = std::find_if(MRI.livein_begin(), MRI.livein_end(),
//                          [&](std::pair<MCRegister, Register> const &e) {
//                            return e.first == Reg.asMCReg();
//                          });
//
//   if (It == MRI.livein_end())
//     return -1;
//   return It - MRI.livein_begin();
// }
//
// static CDSLInstr::Field const *getArgField(MachineRegisterInfo &MRI,
//                                            Register Reg) {
//   uint Idx = getArgIdx(MRI, Reg);
//   if (Idx > CurInstr->fields.size())
//     return nullptr;
//   return &CurInstr->fields[Idx];
// }
//
// static auto getArgInfo(MachineRegisterInfo &MRI, Register Reg) {
//   return std::make_pair(getArgIdx(MRI, Reg), getArgField(MRI, Reg));
// }
//
// static std::pair<PatternError, std::unique_ptr<PatternNode>>
// traverse(MachineRegisterInfo &MRI, MachineInstr &Cur) {
//
//   switch (Cur.getOpcode()) {
//   case TargetOpcode::G_BUILD_VECTOR: {
//     size_t N = Cur.getNumOperands();
//     auto [Err, operands] = traverseNOpOperands(MRI, Cur, N - 1);
//     if (Err)
//       return std::make_pair(Err, nullptr);
//     assert(Cur.getOperand(0).isReg() && "expected register");
//     auto Node = std::make_unique<NOpNode>(
//         MRI.getType(Cur.getOperand(0).getReg()), Cur.getOpcode(),
//         std::move(operands));
//         // std::move(operands));
//
//     return std::make_pair(SUCCESS, std::move(Node));
//   }
//   case TargetOpcode::G_SELECT:
//   case TargetOpcode::G_INSERT_VECTOR_ELT: {
//     auto [Err, NodeFirst, NodeSecond, NodeThird] = traverseTernopOperands(MRI, Cur);
//     if (Err)
//       return std::make_pair(Err, nullptr);
//
//     assert(Cur.getOperand(0).isReg() && "expected register");
//     auto Node = std::make_unique<TernopNode>(
//         MRI.getType(Cur.getOperand(0).getReg()), Cur.getOpcode(),
//         std::move(NodeFirst), std::move(NodeSecond), std::move(NodeThird));
//
//     return std::make_pair(SUCCESS, std::move(Node));
//   }
//   case TargetOpcode::G_SHUFFLE_VECTOR: {
//     assert(Cur.getOperand(1).isReg() && "expected register");
//     auto *First = MRI.getOneDef(Cur.getOperand(1).getReg());
//     if (!First)
//       return std::make_pair(PatternError(FORMAT, &Cur), nullptr);
//     assert(Cur.getOperand(2).isReg() && "expected register");
//     auto *Second = MRI.getOneDef(Cur.getOperand(2).getReg());
//     if (!Second)
//       return std::make_pair(PatternError(FORMAT, &Cur), nullptr);
//     assert(Cur.getOperand(3).isShuffleMask() && "expected shufflemask");
//     ArrayRef<int> Mask = Cur.getOperand(3).getShuffleMask();
//     // if (!Mask)
//     //   return std::make_pair(PatternError(FORMAT, &Cur), nullptr);
//
//     auto [ErrFirst, NodeFirst] = traverse(MRI, *First->getParent());
//     if (ErrFirst)
//       return std::make_pair(ErrFirst, nullptr);
//
//     auto [ErrSecond, NodeSecond] = traverse(MRI, *Second->getParent());
//     if (ErrSecond)
//       return std::make_pair(ErrSecond, nullptr);
//
//     assert(Cur.getOperand(0).isReg() && "expected register");
//     auto Node = std::make_unique<ShuffleNode>(
//         MRI.getType(Cur.getOperand(0).getReg()), Cur.getOpcode(),
//         std::move(NodeFirst), std::move(NodeSecond), Mask);
//
//     return std::make_pair(SUCCESS, std::move(Node));
//   }
//   case TargetOpcode::G_ADD:
//   case TargetOpcode::G_PTR_ADD:
//   case TargetOpcode::G_SUB:
//   case TargetOpcode::G_MUL:
//   case TargetOpcode::G_SDIV:
//   case TargetOpcode::G_UDIV:
//   case TargetOpcode::G_SREM:
//   case TargetOpcode::G_UREM:
//   case TargetOpcode::G_AND:
//   case TargetOpcode::G_OR:
//   case TargetOpcode::G_XOR:
//   case TargetOpcode::G_SMAX:
//   case TargetOpcode::G_UMAX:
//   case TargetOpcode::G_SMIN:
//   case TargetOpcode::G_UMIN:
//   case TargetOpcode::G_EXTRACT_VECTOR_ELT:
//   case TargetOpcode::G_SHL:
//   case TargetOpcode::G_LSHR:
//   case TargetOpcode::G_ASHR: {
//
//     auto [Err, NodeL, NodeR] = traverseBinopOperands(MRI, Cur);
//     if (Err)
//       return std::make_pair(Err, nullptr);
//
//     assert(Cur.getOperand(0).isReg() && "expected register");
//     auto Node = std::make_unique<BinopNode>(
//         MRI.getType(Cur.getOperand(0).getReg()), Cur.getOpcode(),
//         std::move(NodeL), std::move(NodeR));
//
//     return std::make_pair(SUCCESS, std::move(Node));
//   }
//   case TargetOpcode::G_SEXT:
//   case TargetOpcode::G_ZEXT:
//   case TargetOpcode::G_VECREDUCE_ADD:
//   case TargetOpcode::G_TRUNC:
//   case TargetOpcode::G_ABS: {
//
//     auto [Err, NodeR] = traverseUnopOperands(MRI, Cur);
//     if (Err)
//       return std::make_pair(Err, nullptr);
//
//     assert(Cur.getOperand(0).isReg() && "expected register");
//     auto Node = std::make_unique<UnopNode>(
//         MRI.getType(Cur.getOperand(0).getReg()), Cur.getOpcode(),
//         std::move(NodeR));
//
//     return std::make_pair(SUCCESS, std::move(Node));
//   }
//   case TargetOpcode::G_BITCAST: {
//     assert(Cur.getOperand(1).isReg() && "expected register");
//     auto *Operand = MRI.getOneDef(Cur.getOperand(1).getReg());
//     if (!Operand)
//       return std::make_pair(PatternError(FORMAT_LOAD, &Cur), nullptr);
//
//     auto [Err, Node] = traverse(MRI, *Operand->getParent());
//     if (Err)
//       return std::make_pair(Err, nullptr);
//
//     // if the bitcasted value is a register access, we need to patch the
//     // register access type
//     if (auto *AsRegNode = llvm::dyn_cast<RegisterNode>(Node.get()))
//     {
//       assert(Cur.getOperand(0).isReg() && "expected register");
//       AsRegNode->Type = MRI.getType(Cur.getOperand(0).getReg());
//       PatternArgs[AsRegNode->RegIdx].ArgTypeStr = lltToRegTypeStr(AsRegNode->Type);
//     }
//
//     return std::make_pair(SUCCESS, std::move(Node));
//   }
//   case TargetOpcode::G_LOAD: {
//
//     int ReadOffset = 0;
//     int ReadSize;
//
//     MachineMemOperand *MMO = *Cur.memoperands_begin();
//     ReadSize = MMO->getSizeInBits();
//
//     assert(Cur.getOperand(1).isReg() && "expected register");
//     auto *Addr = MRI.getOneDef(Cur.getOperand(1).getReg());
//     if (!Addr)
//       return std::make_pair(PatternError(FORMAT_LOAD, &Cur), nullptr);
//     auto *AddrI = Addr->getParent();
//
//     if (AddrI->getOpcode() == TargetOpcode::G_PTR_ADD) {
//       assert(AddrI->getOperand(1).isReg());
//       auto *BaseAddr =
//           MRI.getOneDef(AddrI->getOperand(1).getReg())->getParent();
//       auto *Offset = MRI.getOneDef(AddrI->getOperand(2).getReg())->getParent();
//       AddrI = BaseAddr;
//
//       if (Offset->getOpcode() != TargetOpcode::G_CONSTANT)
//         return std::make_pair(PatternError(FORMAT_LOAD, Offset), nullptr);
//
//       ReadOffset = Offset->getOperand(1).getCImm()->getLimitedValue();
//     }
//     if (AddrI->getOpcode() != TargetOpcode::COPY)
//       return std::make_pair(PatternError(FORMAT_LOAD, AddrI), nullptr);
//
//     assert(Cur.getOperand(1).isReg() && "expected register");
//     auto AddrLI = AddrI->getOperand(1).getReg();
//     if (!MRI.isLiveIn(AddrLI) || !AddrLI.isPhysical())
//       return std::make_pair(PatternError(FORMAT_LOAD, AddrI), nullptr);
//
//     auto [Idx, Field] = getArgInfo(MRI, AddrLI);
//     if (Field == nullptr)
//       return std::make_pair(PatternError(FORMAT_LOAD, AddrI), nullptr);
//
//     PatternArgs[Idx].Llt = MRI.getType(Cur.getOperand(0).getReg());
//     PatternArgs[Idx].ArgTypeStr = lltToRegTypeStr(PatternArgs[Idx].Llt);
//     PatternArgs[Idx].In = true;
//
//     assert(Cur.getOperand(0).isReg() && "expected register");
//     auto Node = std::make_unique<RegisterNode>(
//         MRI.getType(Cur.getOperand(0).getReg()), Field->ident, Idx, false,
//         ReadOffset, ReadSize, false);
//
//     return std::make_pair(SUCCESS, std::move(Node));
//   }
//   case TargetOpcode::G_CONSTANT: {
//     auto *Imm = Cur.getOperand(1).getCImm();
//     assert(Cur.getOperand(0).isReg() && "expected register");
//     return std::make_pair(SUCCESS, std::make_unique<ConstantNode>(
//                                        MRI.getType(Cur.getOperand(0).getReg()),
//                                        Imm->getLimitedValue()));
//   }
//   case TargetOpcode::G_IMPLICIT_DEF: {
//     assert(Cur.getOperand(0).isReg() && "expected register");
//     return std::make_pair(SUCCESS, std::make_unique<ConstantNode>(
//                                        MRI.getType(Cur.getOperand(0).getReg()),
//                                        0));
//   }
//   case TargetOpcode::G_ICMP: {
//     auto Pred = Cur.getOperand(1);
//     auto [Err, NodeL, NodeR] = traverseBinopOperands(MRI, Cur, 2);
//     if (Err)
//       return std::make_pair(Err, nullptr);
//
//     assert(Cur.getOperand(0).isReg() && "expected register");
//     return std::make_pair(SUCCESS, std::make_unique<CompareNode>(
//                                        MRI.getType(Cur.getOperand(0).getReg()),
//                                        (CmpInst::Predicate)Pred.getPredicate(),
//                                        std::move(NodeL), std::move(NodeR)));
//   }
//   case TargetOpcode::COPY: {
//     // Immediate Operands
//     assert(Cur.getOperand(1).isReg() && "expected register");
//     auto Reg = Cur.getOperand(1).getReg();
//     auto [Idx, Field] = getArgInfo(MRI, Reg);
//
//     PatternArgs[Idx].In = true;
//     PatternArgs[Idx].Llt = LLT();
//     PatternArgs[Idx].ArgTypeStr = makeImmTypeStr(Field->len, Field->type & CDSLInstr::SIGNED);
//
//     if (Field == nullptr)
//       return std::make_pair(FORMAT_IMM, nullptr);
//
//     assert(Cur.getOperand(0).isReg() && "expected register");
//     return std::make_pair(SUCCESS, std::make_unique<RegisterNode>(
//                                        MRI.getType(Cur.getOperand(0).getReg()),
//                                        Field->ident, Idx, true, 0, Field->len,
//                                        Field->type & CDSLInstr::SIGNED));
//   }
//   }
//
//   return std::make_pair(PatternError(FORMAT, &Cur), nullptr);
// }
//
// static std::pair<PatternError, std::unique_ptr<PatternNode>>
// generatePattern(MachineFunction &MF) {
//
//   if (MF.size() != 1)
//     return std::make_pair(MULTIPLE_BLOCKS, nullptr);
//
//   MachineBasicBlock &BB = *MF.begin();
//   MachineRegisterInfo &MRI = MF.getRegInfo();
//
//   auto Instrs = BB.instr_rbegin();
//   auto InstrsEnd = BB.instr_rend();
//
//   // We expect the pattern block to end with a return immediately preceeded by a
//   // store which stores the destination register value.
//
//   if (Instrs == InstrsEnd || !Instrs->isReturn())
//     return std::make_pair(FORMAT_RETURN, nullptr);
//   Instrs++;
//   if (Instrs == InstrsEnd || Instrs->getOpcode() != TargetOpcode::G_STORE)
//     return std::make_pair(FORMAT_STORE, nullptr);
//
//   auto &Store = *Instrs;
//   MachineMemOperand *MMO = *Store.memoperands_begin();
//   if (MMO->getSizeInBits() != 32)
//     return std::make_pair(FORMAT_STORE, nullptr);
//
//   auto *Addr = MRI.getOneDef(Store.getOperand(1).getReg());
//   if (Addr == nullptr || (Addr = MRI.getOneDef(Addr->getReg())) == nullptr ||
//       Addr->getParent()->getOpcode() != TargetOpcode::COPY)
//     return std::make_pair(FORMAT_STORE, nullptr);
//
//   auto [Idx, Field] =
//       getArgInfo(MRI, Addr->getParent()->getOperand(1).getReg());
//   PatternArgs[Idx].Out = true;
//
//   auto *RootO = MRI.getOneDef(Store.getOperand(0).getReg());
//   if (RootO == nullptr)
//     return std::make_pair(FORMAT_STORE, nullptr);
//   auto *Root = RootO->getParent();
//   {
//     LLT Type;
//     if (Root->getOpcode() == TargetOpcode::G_BITCAST)
//       Type = MRI.getType(Root->getOperand(1).getReg());
//     else
//       Type = MRI.getType(Root->getOperand(0).getReg());
//     PatternArgs[Idx].Llt = Type;
//     PatternArgs[Idx].ArgTypeStr = lltToRegTypeStr(Type);
//   }
//
//   return traverse(MRI, *Root);
// }




bool MyPass::runOnMachineFunction(MachineFunction &MF) {
  const TargetInstrInfo *TII = MF.getSubtarget().getInstrInfo();  // TODO: move to constructor?
  llvm::outs() << "MyPass" << "\n";
  const Module *M = nullptr;
  const llvm::Function *F = nullptr;
  F = &MF.getFunction();
  M = F->getParent();
  // std::string module_name = "moduleABC";
  std::string module_name = M->getName().str();
  MachineRegisterInfo &MRI = MF.getRegInfo();
  mg_session *session = connect_to_db("localhost", 7687);
#if PURGE_DB
  auto del = "MATCH (n) DETACH DELETE n;";
  exec_qeury(session, del);
#endif  // PURGE_DB
  std::string f_name = MF.getName().str();
  // llvm::outs() << "f_name=" << f_name << std::endl;
  // std::unordered_map<MachineOperand, std::string> op_instr;
  // std::unordered_map<std::string, MachineInstr> op_instr;
  for (MachineBasicBlock &bb : MF) {
    std::string bb_name = get_bb_name(&bb);
    // llvm::outs() << "bb_name=" << bb_name.c_str() << std::endl;
    std::cout << "bb_name=" << bb_name.c_str() << std::endl;
    for (MachineBasicBlock *suc_bb : successors(&bb)) {
      // llvm::outs() << "suc_bb=?" << std::endl;
      std::cout << "suc_bb=?" << "\n";
      connect_bbs(session, &bb, suc_bb, f_name, module_name);
    }
    for (MachineInstr &MI : bb) {
      std::string inst_str = llvm_to_string(&MI);
      std::string name = std::string(TII->getName(MI.getOpcode()));
      std::cout << "name=" << name << "\n";
      // llvm::outs() << "   " << inst_str;
      std::cout << "> " << inst_str << "\n";
      // Instruction::op_iterator opEnd = MI.op_end();
      // for (const MachineOperand &MO : MI.operands()) {
      bool isLabel = false;
      for (const MachineOperand &MO : llvm::drop_begin(MI.operands())) {
        // std::cout << "MO=?" << "\n";
        // std::cout << "MO=" << MO << "\n";
        std::string src_str = llvm_to_string(&MO);
        std::string src_op_name = "Const";
        llvm::outs() << "MO=" << MO << "\n";
        switch (MO.getType()) {
          case MachineOperand::MO_Register: {
            std::cout << "=> REG" << "\n";
            auto reg = MO.getReg();
            std::cout << "reg=" << reg << "\n";
            for (MachineInstr &RI : MRI.def_instructions(reg)) {
              src_str = llvm_to_string(&RI);
              src_op_name = std::string(TII->getName(RI.getOpcode()));
              std::cout << "src_op_name=" << name << "\n";
              // llvm::outs() << "   " << inst_str;
              std::cout << ">> " << src_str << "\n";
            }
            break;
          }
          case MachineOperand::MO_Immediate:
          case MachineOperand::MO_CImmediate:
          case MachineOperand::MO_FPImmediate: {
            std::cout << "=> IMM" << "\n";
            break;
          }
          case MachineOperand::MO_GlobalAddress: {
            std::cout << "=> GA" << "\n";
            isLabel = true;
            break;
          }
          case MachineOperand::MO_MachineBasicBlock: {
            std::cout << "=> MBB" << "\n";
            isLabel = true;
            break;
          }
          // case MachineOperand::MO_FrameIndex: {
          //   std::cout << "=> FI" << "\n";
          //   break;
          // }
          // case MachineOperand::MO_ConstantPoolIndex: {
          //   std::cout << "=> CPI" << "\n";
          //   break;
          // }
          // case MachineOperand::MO_TargetIndex: {
          //   std::cout << "=> TI" << "\n";
          //   break;
          // }
          // case MachineOperand::MO_JumpTableIndex: {
          //   std::cout << "=> JTI" << "\n";
          //   break;
          // }
          // case MachineOperand::MO_ExternalSymbol: {
          //   std::cout << "=> ES" << "\n";
          //   break;
          // }
          // case MachineOperand::MO_BlockAddress: {
          //   std::cout << "=> BA" << "\n";
          //   break;
          // }
          // case MachineOperand::MO_RegisterMask: {
          //   std::cout << "=> RM" << "\n";
          //   break;
          // }
          // case MachineOperand::MO_RegisterLiveOut: {
          //   std::cout << "=> RLO" << "\n";
          //   break;
          // }
          // case MachineOperand::MO_MCSymbol: {
          //   std::cout << "=> MCS" << "\n";
          //   break;
          // }
          // case MachineOperand::MO_DbgInstrRef: {
          //   std::cout << "=> DIR" << "\n";
          //   break;
          // }
          // case MachineOperand::MO_CFIIndex: {
          //   std::cout << "=> CFII" << "\n";
          //   break;
          // }
          // case MachineOperand::MO_Metadata: {
          //   std::cout << "=> MD" << "\n";
          //   break;
          // }
          // case MachineOperand::MO_IntrinsicID: {
          //   std::cout << "=> IID" << "\n";
          //   break;
          // }
          // case MachineOperand::MO_Predicate: {
          //   std::cout << "=> PC" << "\n";
          //   break;
          // }
          // case MachineOperand::MO_ShuffleMask: {
          //   std::cout << "=> SM" << "\n";
          //   break;
          // }
          default: {
            std::cout << "DEFAULT" << "\n";
            llvm_unreachable("Not Implemented!");
          }
        }
        if (isLabel) {
          continue;
        }
        // MachineInstr *src_inst = dyn_cast<MachineInstr>(MO);
        connect_insts(session, src_str, src_op_name, inst_str, name, f_name, module_name);
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
