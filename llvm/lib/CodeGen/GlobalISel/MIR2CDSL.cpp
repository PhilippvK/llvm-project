//===- llvm/CodeGen/GlobalISel/MIR2CDSL.cpp - MIR2CDSL ---==//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
/// \file
/// This file implements the MIR2CDSL class.
//===----------------------------------------------------------------------===//

#include <iostream>

#include "llvm/CodeGen/GlobalISel/MIR2CDSL.h"
#include "llvm/CodeGen/GlobalISel/CDSLGen.h"
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

#include <vector>


#define PURGE_DB false
#define FORCE_ENABLE false
// #define FORCE_ENABLE true
#define DEBUG true  // TODO: use -debug flag of llvm
#define NOOP false

#define DEBUG_TYPE "mir2cdsl"

using namespace llvm;

static cl::opt<bool>
    EnablePass("mir2cdsl-enable", cl::desc("Enable MIR2CDSL"));


char MIR2CDSL::ID = 0;
INITIALIZE_PASS_BEGIN(
    MIR2CDSL, DEBUG_TYPE,
    "Generate CDFG and store in memgraph platform", false,
    false)
INITIALIZE_PASS_DEPENDENCY(TargetPassConfig)
INITIALIZE_PASS_DEPENDENCY(GISelKnownBitsAnalysis)
INITIALIZE_PASS_DEPENDENCY(ProfileSummaryInfoWrapperPass)
INITIALIZE_PASS_DEPENDENCY(LazyBlockFrequencyInfoPass)
INITIALIZE_PASS_END(
    MIR2CDSL, DEBUG_TYPE,
    "Generate CDFG and store in memgraph platform", false,
    false)

MIR2CDSL::MIR2CDSL(CodeGenOptLevel OL)
    : MachineFunctionPass(ID), OptLevel(OL) {}

// In order not to crash when calling getAnalysis during testing with -run-pass
// we use the default opt level here instead of None, so that the addRequired()
// calls are made in getAnalysisUsage().
MIR2CDSL::MIR2CDSL()
    : MachineFunctionPass(ID), OptLevel(CodeGenOptLevel::Default) {}

void MIR2CDSL::getAnalysisUsage(AnalysisUsage &AU) const {
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


bool MIR2CDSL::runOnMachineFunction(MachineFunction &MF) {

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
     llvm::errs() << "skipping MIR2CDSL in func '" << f_name << "' due to gisel failure" << "\n";
     return true;
  }
  const TargetInstrInfo *TII = MF.getSubtarget().getInstrInfo();  // TODO: move to constructor?
#if DEBUG
  llvm::outs() << "Running MIR2CDSL on function '" << f_name << "' of module '" << module_name << "'" << "\n";
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
  runCDSLGenPipeline(MRI, *Cur, MF);
  return true;
}
