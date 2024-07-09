//===- llvm/CodeGen/GlobalISel/RISCVMIR2CDSL.cpp - RISCVMIR2CDSL ---==//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
/// \file
/// This file implements the RISCVMIR2CDSL class.
//===----------------------------------------------------------------------===//

#include <iostream>

// #include "llvm/ADT/PostOrderIterator.h"
// #include "llvm/ADT/ScopeExit.h"
// #include "llvm/Analysis/LazyBlockFrequencyInfo.h"
// #include "llvm/Analysis/ProfileSummaryInfo.h"
// #include "llvm/CodeGen/GlobalISel/GISelKnownBits.h"
// #include "llvm/CodeGen/GlobalISel/InstructionSelector.h"
// #include "llvm/CodeGen/GlobalISel/LegalizerInfo.h"
// #include "llvm/CodeGen/TargetInstrInfo.h"
// #include "llvm/CodeGen/GlobalISel/Utils.h"
// #include "llvm/CodeGen/ISDOpcodes.h"
// #include "llvm/CodeGen/LowLevelType.h"
// #include "llvm/CodeGen/MachineBasicBlock.h"
// #include "llvm/CodeGen/MachineFrameInfo.h"
// #include "llvm/CodeGen/MachineFunction.h"
// #include "llvm/CodeGen/MachineInstr.h"
// #include "llvm/CodeGen/MachineMemOperand.h"
// #include "llvm/CodeGen/MachineOptimizationRemarkEmitter.h"
// #include "llvm/CodeGen/MachineRegisterInfo.h"
// #include "llvm/CodeGen/TargetLowering.h"
// #include "llvm/CodeGen/TargetOpcodes.h"
// #include "llvm/CodeGen/TargetPassConfig.h"
// #include "llvm/CodeGen/TargetSubtargetInfo.h"
// #include "llvm/Config/config.h"
// #include "llvm/IR/Function.h"
// #include "llvm/IR/InstrTypes.h"
// #include "llvm/MC/TargetRegistry.h"
// #include "llvm/Support/Casting.h"
// #include "llvm/Support/CodeGenCoverage.h"
// #include "llvm/Support/CommandLine.h"
// #include "llvm/Support/Debug.h"
// #include "llvm/Support/TypeSize.h"
// #include "llvm/Support/raw_ostream.h"
// #include "llvm/Target/TargetMachine.h"
// #include "llvm/Transforms/Utils/PredicateInfo.h"

#include "MCTargetDesc/RISCVMatInt.h"
#include "RISCV.h"
#include "RISCVInstrInfo.h"
#include "RISCVTargetMachine.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"

// #include "RISCVMIR2CDSL.h"
#include "RISCVCDSLGen.h"
#include <memory>
#include <sstream>
#include <string>
#include <utility>
#include <unordered_set>

#include <vector>


#define PURGE_DB false
#define FORCE_ENABLE false
// #define FORCE_ENABLE true
#define DEBUG true  // TODO: use -debug flag of llvm
#define NOOP false

#define DEBUG_TYPE "riscv-mir2cdsl"

using namespace llvm;

static cl::opt<bool>
    EnablePass("riscv-mir2cdsl-enable", cl::desc("Enable RISCVMIR2CDSL"));

namespace {

// char RISCVMIR2CDSL::ID = 0;

// RISCVMIR2CDSL::RISCVMIR2CDSL(CodeGenOptLevel OL)
//     : MachineFunctionPass(ID), OptLevel(OL) {}
//
// // In order not to crash when calling getAnalysis during testing with -run-pass
// // we use the default opt level here instead of None, so that the addRequired()
// // calls are made in getAnalysisUsage().
// RISCVMIR2CDSL::RISCVMIR2CDSL()
//     : MachineFunctionPass(ID), OptLevel(CodeGenOptLevel::Default) {}
//
// void RISCVMIR2CDSL::getAnalysisUsage(AnalysisUsage &AU) const {
//   // AU.addRequired<TargetPassConfig>();
//   // AU.addRequired<GISelKnownBitsAnalysis>();
//   // AU.addPreserved<GISelKnownBitsAnalysis>();
//   AU.setPreservesAll();
//
//   // if (OptLevel != CodeGenOptLevel::None) {
//   //   AU.addRequired<ProfileSummaryInfoWrapperPass>();
//   //   LazyBlockFrequencyInfoPass::getLazyBFIAnalysisUsage(AU);
//   // }
//   // getSelectionDAGFallbackAnalysisUsage(AU);
//   MachineFunctionPass::getAnalysisUsage(AU);
// }

class RISCVMIR2CDSL  : public MachineFunctionPass {
public:
  // const RISCVInstrInfo *TII;
  static char ID;

  RISCVMIR2CDSL() : MachineFunctionPass(ID) {}

  bool runOnMachineFunction(MachineFunction &MF) override;

  // StringRef getPassName() const override {
  //   return RISCV_POST_RA_EXPAND_PSEUDO_NAME;
  // }

private:
  // bool expandMBB(MachineBasicBlock &MBB);
  // bool expandMI(MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI,
  //               MachineBasicBlock::iterator &NextMBBI);
  // bool expandMovImm(MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI);
  // bool expandMovAddr(MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI);
};

char RISCVMIR2CDSL::ID = 0;


bool RISCVMIR2CDSL::runOnMachineFunction(MachineFunction &MF) {

  if (!EnablePass && !FORCE_ENABLE) {
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
     MachineFunctionProperties::Property::FailedISel)) {
     llvm::errs() << "skipping RISCVMIR2CDSL in func '" << f_name << "' due to gisel failure" << "\n";
     return true;
  }
  const TargetInstrInfo *TII = MF.getSubtarget().getInstrInfo();  // TODO: move to constructor?
#if DEBUG
  llvm::outs() << "Running RISCVMIR2CDSL on function '" << f_name << "' of module '" << module_name << "'" << "\n";
#endif
  MachineRegisterInfo &MRI = MF.getRegInfo();
  // const TargetRegisterInfo *TRI = MF.getSubtarget().getRegisterInfo();
  // TODO: assert single bb
  // get last instruction! (There should be a better way?)
  MachineInstr* Cur;
  for (MachineBasicBlock &bb : MF) {
    for (MachineInstr &MI : bb) {
        Cur = &MI;
    }
  }
  runRISCVCDSLGenPipeline(MRI, *Cur, MF);
  return true;
}
} // end of anonymous namespace

#include "llvm/ADT/StringRef.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/Support/CodeGen.h"

INITIALIZE_PASS(RISCVMIR2CDSL, "riscv-mir2cdsl",
                "TODO", false, false)
namespace llvm {

FunctionPass *createRISCVMIR2CDSLPass() {
  return new RISCVMIR2CDSL();
}

} // end of namespace llvm
