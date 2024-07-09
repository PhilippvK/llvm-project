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

#include "RISCVCDSLGen.h"

#define DEBUG_TYPE "cdsl-gen"

#include "RISCVRegisterBankInfo.h"
#include "RISCVSubtarget.h"
#include "RISCVTargetMachine.h"

#include "llvm/ADT/SmallVector.h"
#include "llvm/CodeGen/GlobalISel/GIMatchTableExecutor.h"
#include "llvm/CodeGen/GlobalISel/GISelChangeObserver.h"
#include "llvm/CodeGen/GlobalISel/MachineIRBuilder.h"
#include "llvm/CodeGen/GlobalISel/Utils.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineOperand.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterBankInfo.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/CodeGen/TargetOpcodes.h"
#include "llvm/CodeGen/TargetRegisterInfo.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/DataLayout.h"
#include "llvm/IR/Type.h"
#include "llvm/Support/CodeGenCoverage.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/LEB128.h"
#include "llvm/Support/raw_ostream.h"
#include <cassert>
#include <cstddef>
#include <cstdint>
#include <filesystem>
#include <fstream>
#include <map>


namespace fs = std::filesystem;

namespace llvm {

static cl::opt<bool> EnableRISCVGMIR2CDSL(
    "riscv-gmir2cdsl",
    cl::desc("TODO"),
    cl::Hidden);
static cl::opt<std::string> RISCVOutDir(
    "riscv-gmir2cdsl-out-dir",
    cl::desc("TODO"),
    cl::value_desc("TODO"),
    // cl::init("."),
    cl::Hidden);

std::map<std::string, int> FuncCounts;

int traverse(MachineRegisterInfo &MRI, MachineInstr &Cur, std::ofstream &OutStream);

std::string lltToString(LLT Llt, bool IsSigned) {
  if (Llt.isFixedVector())
    return "?vector?";  // TODO
  if (Llt.isScalar()) {
    std::string Str = "";
    if (IsSigned)
      Str += std::string("signed");
    else
      Str += std::string("unsigned");
    Str += std::string("<");
    Str += std::to_string(Llt.getSizeInBits());
    Str += std::string(">");
    return Str;
  }
  assert(0 && "invalid type");
}

int traverse(MachineRegisterInfo &MRI, MachineInstr &Cur, std::ofstream &OutStream) {

  // DEBUG_WITH_TYPE("gmir2cdsl", dbgs() << "traverse" << "\n");
  auto Opcode = Cur.getOpcode();
  switch (Opcode) {
  case TargetOpcode::G_BUILD_VECTOR:
  case TargetOpcode::G_INSERT_VECTOR_ELT:
  case TargetOpcode::G_EXTRACT_VECTOR_ELT:
  case TargetOpcode::G_SHUFFLE_VECTOR:
  case TargetOpcode::G_PTR_ADD:
  case TargetOpcode::G_VECREDUCE_ADD:
  case TargetOpcode::G_IMPLICIT_DEF: {
    DEBUG_WITH_TYPE("gmir2cdsl", dbgs() << "Unsupported opcode: ?" << "\n");
    return -3;
  }
  // reg imm
  case RISCV::SLLI: {
    static const std::unordered_map<int, std::string> BinopStr = {
        {RISCV::SLLI, "<<"},
    };

    std::string OpString = std::string(BinopStr.at(Opcode));
    assert(Cur.getOperand(1).isReg() && "expected register");
    auto *LHS = MRI.getOneDef(Cur.getOperand(1).getReg());
    if (!LHS)
      return -16;
    assert(Cur.getOperand(2).isCImm() && "expected cimm");
    // assert(Cur.getOperand(2).isImm() && "expected imm");
    // auto *RHS = MRI.getOneDef(Cur.getOperand(2).getImm());
    // auto *RHS = MRI.getOneDef(Cur.getOperand(2).getCImm());
    // if (!RHS)
    //   return -17;
    auto *Imm = Cur.getOperand(2).getCImm();
    auto Val = Imm->getLimitedValue();
    // std::string TypeStr = lltToString(Type, true);
    // TODO: OutStream << "(" << TypeStr << ")";

    OutStream << "(";
    auto ErrL = traverse(MRI, *LHS->getParent(), OutStream);
    if (ErrL)
      return -18;
    OutStream << OpString;
    OutStream << "(";
    OutStream << Val;
    OutStream << ")";
    OutStream << ")";

    assert(Cur.getOperand(0).isReg() && "expected register");
    // auto Node = std::make_unique<BinopNode>(
    //     MRI.getType(Cur.getOperand(0).getReg()), Cur.getOpcode(),
    //     std::move(NodeL), std::move(NodeR));

    return 0;
  }
  // reg reg
  case TargetOpcode::G_SHL:
  case TargetOpcode::G_LSHR:
  case TargetOpcode::G_ASHR:
  case TargetOpcode::G_SUB:
  case TargetOpcode::G_MUL:
  case TargetOpcode::G_SDIV:
  case TargetOpcode::G_UDIV:
  case TargetOpcode::G_SREM:
  case TargetOpcode::G_UREM:
  case TargetOpcode::G_AND:
  case TargetOpcode::G_OR:
  case TargetOpcode::G_XOR:
  case TargetOpcode::G_ADD: {
    static const std::unordered_map<int, std::string> BinopStr = {
        {TargetOpcode::G_ADD, "+"},
        {TargetOpcode::G_SUB, "-"},
        {TargetOpcode::G_MUL, "*"},
        {TargetOpcode::G_SDIV, "/"},  // TODO: handle sign
        {TargetOpcode::G_UDIV, "/"},  // TODO: handle sign
        {TargetOpcode::G_SREM, "%"},  // TODO: handle sign
        {TargetOpcode::G_UREM, "%"},  // TODO: handle sign
        {TargetOpcode::G_AND, "&"},
        {TargetOpcode::G_OR, "|"},
        {TargetOpcode::G_XOR, "^"},
        // {TargetOpcode::G_SHL, "<<"},
        {TargetOpcode::G_LSHR, ">>"},
        {TargetOpcode::G_ASHR, ">>"},  // TODO: arithmetic
    };

    std::string OpString = std::string(BinopStr.at(Opcode));
    assert(Cur.getOperand(1).isReg() && "expected register");
    auto *LHS = MRI.getOneDef(Cur.getOperand(1).getReg());
    if (!LHS)
      return -16;
    assert(Cur.getOperand(2).isReg() && "expected register");
    auto *RHS = MRI.getOneDef(Cur.getOperand(2).getReg());
    if (!RHS)
      return -17;

    OutStream << "(";
    auto ErrL = traverse(MRI, *LHS->getParent(), OutStream);
    if (ErrL)
      return -18;
    OutStream << OpString;
    auto ErrR = traverse(MRI, *RHS->getParent(), OutStream);
    if (ErrR)
      return -19;
    OutStream << ")";

    assert(Cur.getOperand(0).isReg() && "expected register");
    // auto Node = std::make_unique<BinopNode>(
    //     MRI.getType(Cur.getOperand(0).getReg()), Cur.getOpcode(),
    //     std::move(NodeL), std::move(NodeR));

    return 0;
  }
  case RISCV::SLT:
  case RISCV::SLTU: {
    assert(Cur.getOperand(1).isReg() && "expected register");
    auto *LHS = MRI.getOneDef(Cur.getOperand(1).getReg());
    if (!LHS)
      return -16;
    assert(Cur.getOperand(2).isReg() && "expected register");
    auto *RHS = MRI.getOneDef(Cur.getOperand(2).getReg());
    if (!RHS)
      return -17;

    OutStream << "(";
    if (Opcode == RISCV::SLT) {
        OutStream << "(signed)";
    } else {
        OutStream << "(unsigned)";
    }
    if (Cur.getOperand(1).getReg().isPhysical()) {
      llvm::outs() << "PHYS" << "\n";
    }
    auto ErrL = traverse(MRI, *LHS->getParent(), OutStream);
    if (ErrL)
      return -18;
    OutStream << "<";
    if (Opcode == RISCV::SLT) {
        OutStream << "(signed)";
    } else {
        OutStream << "(unsigned)";
    }
    auto ErrR = traverse(MRI, *RHS->getParent(), OutStream);
    if (ErrR)
      return -19;
    OutStream << "?";
    OutStream << "1";
    OutStream << ":";
    OutStream << "0";
    OutStream << ")";

    assert(Cur.getOperand(0).isReg() && "expected register");
    // auto Node = std::make_unique<BinopNode>(
    //     MRI.getType(Cur.getOperand(0).getReg()), Cur.getOpcode(),
    //     std::move(NodeL), std::move(NodeR));

    return 0;
  }
  case TargetOpcode::G_SMIN:
  case TargetOpcode::G_UMIN:
  case TargetOpcode::G_UMAX:
  case TargetOpcode::G_SMAX: {
    assert(Cur.getOperand(1).isReg() && "expected register");
    auto *LHS = MRI.getOneDef(Cur.getOperand(1).getReg());
    if (!LHS)
      return -16;
    assert(Cur.getOperand(2).isReg() && "expected register");
    auto *RHS = MRI.getOneDef(Cur.getOperand(2).getReg());
    if (!RHS)
      return -17;

    OutStream << "(";
    if (Opcode == TargetOpcode::G_SMIN || Opcode == TargetOpcode::G_SMAX) {
        OutStream << "(signed)";
    } else {
        OutStream << "(unsigned)";
    }
    auto ErrL = traverse(MRI, *LHS->getParent(), OutStream);
    if (ErrL)
      return -18;
    if (Opcode == TargetOpcode::G_SMAX || Opcode == TargetOpcode::G_UMAX) {
        OutStream << ">";
    } else if (Opcode == TargetOpcode::G_SMIN || Opcode == TargetOpcode::G_UMIN) {
        OutStream << "<";
    } else {
      return -21;
    }
    if (Opcode == TargetOpcode::G_SMIN || Opcode == TargetOpcode::G_SMAX) {
        OutStream << "(signed)";
    } else {
        OutStream << "(unsigned)";
    }
    auto ErrR = traverse(MRI, *RHS->getParent(), OutStream);
    if (ErrR)
      return -19;
    OutStream << "?";
    ErrL = traverse(MRI, *LHS->getParent(), OutStream);
    if (ErrL)
      return -18;
    OutStream << ":";
    ErrR = traverse(MRI, *RHS->getParent(), OutStream);
    if (ErrR)
      return -19;
    OutStream << ")";

    assert(Cur.getOperand(0).isReg() && "expected register");
    // auto Node = std::make_unique<BinopNode>(
    //     MRI.getType(Cur.getOperand(0).getReg()), Cur.getOpcode(),
    //     std::move(NodeL), std::move(NodeR));

    return 0;
  }
  case TargetOpcode::G_SELECT: {
    assert(Cur.getOperand(1).isReg() && "expected register");
    auto *Cmp = MRI.getOneDef(Cur.getOperand(1).getReg());
    if (!Cmp)
      return -16;
    assert(Cur.getOperand(2).isReg() && "expected register");
    auto *LHS = MRI.getOneDef(Cur.getOperand(2).getReg());
    if (!LHS)
      return -17;
    assert(Cur.getOperand(3).isReg() && "expected register");
    auto *RHS = MRI.getOneDef(Cur.getOperand(3).getReg());
    if (!RHS)
      return -18; // resolve overlap

    OutStream << "(";
    auto ErrC = traverse(MRI, *Cmp->getParent(), OutStream);
    if (ErrC)
      return -18;
    OutStream << "?";
    auto ErrL = traverse(MRI, *LHS->getParent(), OutStream);
    if (ErrL)
      return -19;
    OutStream << ":";
    auto ErrR = traverse(MRI, *RHS->getParent(), OutStream);
    if (ErrR)
      return -20; // resolve overlap
    OutStream << ")";

    assert(Cur.getOperand(0).isReg() && "expected register");
    // auto Node = std::make_unique<BinopNode>(
    //     MRI.getType(Cur.getOperand(0).getReg()), Cur.getOpcode(),
    //     std::move(NodeL), std::move(NodeR));

    return 0;
  }
  case TargetOpcode::G_ICMP: {
    static const std::unordered_map<unsigned, std::string> cmpStr = {
        {CmpInst::Predicate::ICMP_EQ, "=="},
        {CmpInst::Predicate::ICMP_NE, "!="},
        {CmpInst::Predicate::ICMP_SLT, "<"},  // TODO: signed
        {CmpInst::Predicate::ICMP_SLE, "<="},  // TODO: signed
        {CmpInst::Predicate::ICMP_SGT, ">"},  // TODO: signed
        {CmpInst::Predicate::ICMP_SGE, ">="},  // TODO: signed
        {CmpInst::Predicate::ICMP_ULT, "<"},  // TODO: unsigned
        {CmpInst::Predicate::ICMP_ULE, "<="},  // TODO: unsigned
        {CmpInst::Predicate::ICMP_UGT, ">"},  // TODO: unsigned
        {CmpInst::Predicate::ICMP_UGE, ">="},  // TODO: unsigned
    };
    auto Cond = Cur.getOperand(1);
    CmpInst::Predicate Pred = (CmpInst::Predicate)Cond.getPredicate();

    assert(Cur.getOperand(2).isReg() && "expected register");
    auto *LHS = MRI.getOneDef(Cur.getOperand(2).getReg());
    if (!LHS)
      return -16;
    assert(Cur.getOperand(3).isReg() && "expected register");
    auto *RHS = MRI.getOneDef(Cur.getOperand(3).getReg());
    if (!RHS)
      return -17;

    OutStream << "(";
    auto ErrL = traverse(MRI, *LHS->getParent(), OutStream);
    if (ErrL)
      return -18;
    OutStream << cmpStr.at(Pred);
    auto ErrR = traverse(MRI, *RHS->getParent(), OutStream);
    if (ErrR)
      return -19;
    OutStream << ")";
    return 0;
  }
  case TargetOpcode::G_ABS:
  case TargetOpcode::G_BITCAST:
  case TargetOpcode::G_LOAD:
  case TargetOpcode::G_STORE: {
    DEBUG_WITH_TYPE("gmir2cdsl", dbgs() << "Unimplemented opcode: ?" << "\n");
    return -3;
  }
  case TargetOpcode::G_CONSTANT: {
    OutStream << "(";
    auto *Imm = Cur.getOperand(1).getCImm();
    assert(Cur.getOperand(0).isReg() && "expected register");
    auto Type = MRI.getType(Cur.getOperand(0).getReg());
    auto Val = Imm->getLimitedValue();
    std::string TypeStr = lltToString(Type, true);
    OutStream << "(" << TypeStr << ")";
    OutStream << Val;
    OutStream << ")";
    return 0;
  }
  case TargetOpcode::COPY: {
    OutStream << "(";
    assert(Cur.getOperand(0).isReg() && "expected register");
    auto Src = Cur.getOperand(1).getReg();
    assert(Cur.getOperand(1).isReg() && "expected register");
    auto Dest = Cur.getOperand(0).getReg();
    // auto *Src_ = MRI.getOneDef(Src);
    auto *TRI = MRI.getTargetRegisterInfo();
    // DEBUG_WITH_TYPE("gmir2cdsl", dbgs() << "MRI.isLiveIn(Src)=" << MRI.isLiveIn(Src) << "\n");
    // DEBUG_WITH_TYPE("gmir2cdsl", dbgs() << "Src.isPhysical()=" << Src.isPhysical() << "\n");
    // DEBUG_WITH_TYPE("gmir2cdsl", dbgs() << "MRI.isLiveIn(Dest)=" << MRI.isLiveIn(Dest) << "\n");
    // DEBUG_WITH_TYPE("gmir2cdsl", dbgs() << "Dest.isPhysical()=" << Dest.isPhysical() << "\n");
    if (MRI.isLiveIn(Src) && Src.isPhysical()) {
      std::string temp;
      llvm::raw_string_ostream temp2(temp);
      temp2 << printReg(Src, TRI, 0, &MRI);
      OutStream << temp;
    } else if (Dest.isPhysical()) {
      assert(Cur.getOperand(1).isReg() && "expected register");
      auto *LHS = MRI.getOneDef(Cur.getOperand(1).getReg());
      if (!LHS)
        return -16;
      auto ErrL = traverse(MRI, *LHS->getParent(), OutStream);
      if (ErrL)
        return -18;
    } else {
      return -20;
    }
    OutStream << ")";
    return 0;
  }
  case TargetOpcode::G_SEXT_INREG: {
    OutStream << "(";
    OutStream << "(?)";
    assert(Cur.getOperand(1).isReg() && "expected register");
    auto *LHS = MRI.getOneDef(Cur.getOperand(1).getReg());
    if (!LHS)
      return -16;
    auto ErrL = traverse(MRI, *LHS->getParent(), OutStream);
    if (ErrL)
      return -18;
    OutStream << ")";

    assert(Cur.getOperand(0).isReg() && "expected register");
    // auto Node = std::make_unique<BinopNode>(
    //     MRI.getType(Cur.getOperand(0).getReg()), Cur.getOpcode(),
    //     std::move(NodeL), std::move(NodeR));

    return 0;
    OutStream << ")";
    return 0;
  }
  case TargetOpcode::G_ASSERT_SEXT:
  case TargetOpcode::G_ASSERT_ZEXT: {
    // DEBUG_WITH_TYPE("gmir2cdsl", dbgs() << "TODO: G_ASSERT_ZEXT/SEXT" << "\n");
    assert(Cur.getOperand(0).isReg() && "expected register");
    assert(Cur.getOperand(1).isReg() && "expected register");
    auto *LHS = MRI.getOneDef(Cur.getOperand(1).getReg());
    if (!LHS)
      return -16;
    // assert(Cur.getOperand(2).isCImm() && "expected imm");
    assert(Cur.getOperand(2).isImm() && "expected imm");
    // auto SrcWidth = Cur.getOperand(2).getCImm()->getLimitedValue();
    auto SrcWidth = Cur.getOperand(2).getImm();
    auto Type = MRI.getType(Cur.getOperand(0).getReg());
    // dbgs() << "SrcWidth=" << SrcWidth << "\n";
    std::string TypeStr = lltToString(Type, Opcode == TargetOpcode::G_ASSERT_SEXT);
    OutStream << "(";
    OutStream << "(";
    OutStream << TypeStr;
    // if (Opcode == TargetOpcode::G_ASSERT_SEXT) {
    //     OutStream << "(signed<?>)";
    // } else if (Opcode == TargetOpcode::G_ASSERT_ZEXT) {
    //     OutStream << "(unsigned<?>)";
    // } else {
    //   return -30;
    // }
    OutStream << ")";
    auto ErrL = traverse(MRI, *LHS->getParent(), OutStream);
    if (ErrL)
      return -18;
    OutStream << "[" << std::to_string(SrcWidth - 1) << ":0]";
    OutStream << ")";
    return 0;
  }
  case TargetOpcode::G_TRUNC:
  case TargetOpcode::G_SEXT:
  case TargetOpcode::G_ZEXT: {
    assert(Cur.getOperand(0).isReg() && "expected register");
    assert(Cur.getOperand(1).isReg() && "expected register");
    auto Type = MRI.getType(Cur.getOperand(0).getReg());
    std::string TypeStr = lltToString(Type, Opcode == TargetOpcode::G_ASSERT_SEXT);
    auto *LHS = MRI.getOneDef(Cur.getOperand(1).getReg());
    if (!LHS)
      return -16;
    OutStream << "(";
    OutStream << "(";
    OutStream << TypeStr;
    OutStream << ")";
    auto ErrL = traverse(MRI, *LHS->getParent(), OutStream);
    if (ErrL)
      return -18;
    if (Opcode == TargetOpcode::G_TRUNC) {
      // TODO: explicit truncation
    }
    OutStream << ")";
    return 0;
  }
  default:
    DEBUG_WITH_TYPE("gmir2cdsl", dbgs() << "Unhandled opcode: ?" << "\n");
    return -2;
  }
  DEBUG_WITH_TYPE("gmir2cdsl", dbgs() << "Missing return from switch" << "\n");
  return -1;
}

void runRISCVCDSLGenPipeline(MachineRegisterInfo &MRI, MachineInstr &Cur, MachineFunction &Func) {
  if (!EnableRISCVGMIR2CDSL) {
      return;
  }
  LLVM_DEBUG(dbgs() << "--- START ---" << "\n");

  std::string FuncName = std::string(Func.getName());
  LLVM_DEBUG(dbgs() << "FuncName: " << FuncName << "\n");

  auto it = FuncCounts.find(FuncName);
  int Id = 0;
  if (it != FuncCounts.end()) {
      // update
      LLVM_DEBUG(dbgs() << "Update!" << "\n");
      Id = it->second;
  } else {
      // add
      LLVM_DEBUG(dbgs() << "Add!" << "\n");
      // FuncCounts.insert({FuncName, 1});
  }
  FuncCounts[FuncName] = Id + 1;
  std::string OutDirStr = RISCVOutDir;
  fs::path OutPath = std::filesystem::u8path(OutDirStr);
  OutPath = OutPath / FuncName;
  std::string OutPathStr = OutPath.string() + "." + std::to_string(Id);
  LLVM_DEBUG(dbgs() << "OutPathStr: " << OutPathStr << "\n");

  std::ofstream OutStream;
  // bool SplitFiles = false;
  bool Append = false;
  if (Append) {
      OutStream.open(OutPathStr, std::ofstream::out | std::ofstream::app);
  } else {
      OutStream.open(OutPathStr, std::ofstream::out);
  }
  if (!OutStream) {
      LLVM_DEBUG(dbgs() << "Could not open: " << OutPath.string() << "\n");
      return;
  }

  bool PrintInstr = true;
  bool PrintSub = true;
  bool BehavOnly = false;
  if (PrintInstr) {
    LLVM_DEBUG(dbgs() << "Current instruction:" << "\n");
    LLVM_DEBUG(Cur.dump());
  }
  if (PrintSub) {
    LLVM_DEBUG(dbgs() << "Current sub:" << "\n");
    LLVM_DEBUG(Cur.dumpr(MRI));
  }
  // LLVM_DEBUG(dbgs() << "Generated CDSL:" << "\n");
  if (!BehavOnly) {
    OutStream << "??? {\n";
    OutStream << "  encoding: ???;\n";
    OutStream << "  assembly: ???;\n";
    OutStream << "  behavior: ";
  }
  // TODO: first build then print...
  // TODO: indent
  OutStream << "X[?]=";
  auto TraverseErr = traverse(MRI, Cur, OutStream);
  OutStream << ";\n";
  if (!BehavOnly) {
    OutStream << "}\n";
  }
  if (TraverseErr)
    LLVM_DEBUG(dbgs() << "TraverseErr -> " << TraverseErr << "\n");
  OutStream.close();
  LLVM_DEBUG(dbgs() << "--- DONE ---" << "\n");
}

} // end namespace llvm
