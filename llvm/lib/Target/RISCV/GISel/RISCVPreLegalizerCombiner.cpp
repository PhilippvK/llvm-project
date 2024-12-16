//=== RISCVPreLegalizerCombiner.cpp ---------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This pass does combining of machine instructions at the generic MI level,
// before the legalizer.
//
//===----------------------------------------------------------------------===//

#include "RISCVSubtarget.h"
#include "llvm/CodeGen/GlobalISel/CSEInfo.h"
#include "llvm/CodeGen/GlobalISel/Combiner.h"
#include "llvm/CodeGen/GlobalISel/CombinerHelper.h"
#include "llvm/CodeGen/GlobalISel/CombinerInfo.h"
#include "llvm/CodeGen/GlobalISel/GIMatchTableExecutorImpl.h"
#include "llvm/CodeGen/GlobalISel/GISelKnownBits.h"
#include "llvm/CodeGen/GlobalISel/MachineIRBuilder.h"
#include "llvm/CodeGen/MachineDominators.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/TargetPassConfig.h"

#define GET_GICOMBINER_DEPS
#include "RISCVGenPreLegalizeGICombiner.inc"
#undef GET_GICOMBINER_DEPS

#define DEBUG_TYPE "riscv-prelegalizer-combiner"

using namespace llvm;

namespace {

// Combines vecreduce_add(mul(ext(x), ext(y))) -> vecreduce_add(udot(x, y))
// Or vecreduce_add(ext(x)) -> vecreduce_add(udot(x, 1))
// Similar to performVecReduceAddCombine in SelectionDAG
bool matchExtAddvToUdotAddv(MachineInstr &MI, MachineRegisterInfo &MRI,
                            const RISCVSubtarget &STI,
                            std::tuple<Register, Register, bool> &MatchInfo) {
  llvm::outs() << "AAA" << "\n";
  assert(MI.getOpcode() == TargetOpcode::G_VECREDUCE_ADD &&
         "Expected a G_VECREDUCE_ADD instruction");
  // assert(STI.hasDotProd() && "Target should have Dot Product feature");

  MachineInstr *I1 = getDefIgnoringCopies(MI.getOperand(1).getReg(), MRI);
  Register DstReg = MI.getOperand(0).getReg();
  Register MidReg = I1->getOperand(0).getReg();
  LLT DstTy = MRI.getType(DstReg);
  LLT MidTy = MRI.getType(MidReg);
  llvm::outs() << "AAA2" << "\n";
  if (DstTy.getScalarSizeInBits() != 32 || MidTy.getScalarSizeInBits() != 32)
    return false;
  llvm::outs() << "AAA3" << "\n";

  LLT SrcTy;
  auto I1Opc = I1->getOpcode();
  if (I1Opc == TargetOpcode::G_MUL) {
    llvm::outs() << "AAA4" << "\n";
    // If result of this has more than 1 use, then there is no point in creating
    // udot instruction
    if (!MRI.hasOneNonDBGUse(MidReg))
      return false;
    llvm::outs() << "AAA5" << "\n";

    MachineInstr *ExtMI1 =
        getDefIgnoringCopies(I1->getOperand(1).getReg(), MRI);
    MachineInstr *ExtMI2 =
        getDefIgnoringCopies(I1->getOperand(2).getReg(), MRI);
    LLT Ext1DstTy = MRI.getType(ExtMI1->getOperand(0).getReg());
    LLT Ext2DstTy = MRI.getType(ExtMI2->getOperand(0).getReg());

    llvm::outs() << "AAA6" << "\n";
    if (ExtMI1->getOpcode() != ExtMI2->getOpcode() || Ext1DstTy != Ext2DstTy)
      return false;
    llvm::outs() << "AAA7" << "\n";
    I1Opc = ExtMI1->getOpcode();
    SrcTy = MRI.getType(ExtMI1->getOperand(1).getReg());
    std::get<0>(MatchInfo) = ExtMI1->getOperand(1).getReg();
    std::get<1>(MatchInfo) = ExtMI2->getOperand(1).getReg();
    llvm::outs() << "AAA8" << "\n";
  } else {
    llvm::outs() << "AAA9" << "\n";
    SrcTy = MRI.getType(I1->getOperand(1).getReg());
    std::get<0>(MatchInfo) = I1->getOperand(1).getReg();
    std::get<1>(MatchInfo) = 0;
    llvm::outs() << "AAA10" << "\n";
  }
  llvm::outs() << "AAA11" << "\n";

  if (I1Opc == TargetOpcode::G_ZEXT)
    std::get<2>(MatchInfo) = 0;
  else if (I1Opc == TargetOpcode::G_SEXT)
    std::get<2>(MatchInfo) = 1;
  else
    return false;
  llvm::outs() << "AAA12" << "\n";
  llvm::outs() << "SrcTy.getScalarSizeInBits()=" << SrcTy.getScalarSizeInBits() << "\n";
  llvm::outs() << "SrcTy.getNumElements()=" << SrcTy.getNumElements() << "\n";

  if (SrcTy.getScalarSizeInBits() != 8 || SrcTy.getNumElements() % 4 != 0)
     return false;
  llvm::outs() << "AAA13" << "\n";

  return true;
}

void applyExtAddvToUdotAddv(MachineInstr &MI, MachineRegisterInfo &MRI,
                            MachineIRBuilder &Builder,
                            GISelChangeObserver &Observer,
                            const RISCVSubtarget &STI,
                            std::tuple<Register, Register, bool> &MatchInfo) {
  llvm::outs() << "BBB" << "\n";
  assert(MI.getOpcode() == TargetOpcode::G_VECREDUCE_ADD &&
         "Expected a G_VECREDUCE_ADD instruction");
  // assert(STI.hasDotProd() && "Target should have Dot Product feature");

  // Initialise the variables
  unsigned DotOpcode =
      std::get<2>(MatchInfo) ? RISCV::G_SDOT : RISCV::G_UDOT;
  Register Ext1SrcReg = std::get<0>(MatchInfo);

  // If there is one source register, create a vector of 0s as the second
  // source register
  Register Ext2SrcReg;
  if (std::get<1>(MatchInfo) == 0)
    Ext2SrcReg = Builder.buildConstant(MRI.getType(Ext1SrcReg), 1)
                     ->getOperand(0)
                     .getReg();
  else
    Ext2SrcReg = std::get<1>(MatchInfo);

  // Find out how many DOT instructions are needed
  LLT SrcTy = MRI.getType(Ext1SrcReg);
  LLT MidTy;
  unsigned NumOfDotMI;
  if (SrcTy.getNumElements() % 4 == 0) {
    NumOfDotMI = SrcTy.getNumElements() / 4;
    // MidTy = LLT::fixed_vector(1, 32);
    MidTy = LLT::scalar(32);
  } else {
    llvm_unreachable("Source type number of elements is not multiple of 4");
  }

  // Handle case where one DOT instruction is needed
  if (NumOfDotMI == 1) {
    auto Zeroes = Builder.buildConstant(MidTy, 0)->getOperand(0).getReg();
    // auto Dot = Builder.buildInstr(DotOpcode, {MidTy},
    //                               {Zeroes, Ext1SrcReg, Ext2SrcReg});
    // Builder.buildVecReduceAdd(MI.getOperand(0), Dot->getOperand(0));
    auto Dot = Builder.buildInstr(DotOpcode, {MI.getOperand(0)},
                                  {Zeroes, Ext1SrcReg, Ext2SrcReg});
  } else {
    llvm_unreachable("NumOfDotMI != 1");
    // // If not pad the last v8 element with 0s to a v16
    // SmallVector<Register, 4> Ext1UnmergeReg;
    // SmallVector<Register, 4> Ext2UnmergeReg;
    // if (SrcTy.getNumElements() % 16 != 0) {
    //   SmallVector<Register> Leftover1;
    //   SmallVector<Register> Leftover2;

    //   // Split the elements into v16i8 and v8i8
    //   LLT MainTy = LLT::fixed_vector(16, 8);
    //   LLT LeftoverTy1, LeftoverTy2;
    //   if ((!extractParts(Ext1SrcReg, MRI.getType(Ext1SrcReg), MainTy,
    //                      LeftoverTy1, Ext1UnmergeReg, Leftover1, Builder,
    //                      MRI)) ||
    //       (!extractParts(Ext2SrcReg, MRI.getType(Ext2SrcReg), MainTy,
    //                      LeftoverTy2, Ext2UnmergeReg, Leftover2, Builder,
    //                      MRI))) {
    //     llvm_unreachable("Unable to split this vector properly");
    //   }

    //   // Pad the leftover v8i8 vector with register of 0s of type v8i8
    //   Register v8Zeroes = Builder.buildConstant(LLT::fixed_vector(8, 8), 0)
    //                           ->getOperand(0)
    //                           .getReg();

    //   Ext1UnmergeReg.push_back(
    //       Builder
    //           .buildMergeLikeInstr(LLT::fixed_vector(16, 8),
    //                                {Leftover1[0], v8Zeroes})
    //           .getReg(0));
    //   Ext2UnmergeReg.push_back(
    //       Builder
    //           .buildMergeLikeInstr(LLT::fixed_vector(16, 8),
    //                                {Leftover2[0], v8Zeroes})
    //           .getReg(0));

    // } else {
    //   // Unmerge the source vectors to v16i8
    //   unsigned SrcNumElts = SrcTy.getNumElements();
    //   extractParts(Ext1SrcReg, LLT::fixed_vector(16, 8), SrcNumElts / 16,
    //                Ext1UnmergeReg, Builder, MRI);
    //   extractParts(Ext2SrcReg, LLT::fixed_vector(16, 8), SrcNumElts / 16,
    //                Ext2UnmergeReg, Builder, MRI);
    // }

    // // Build the UDOT instructions
    // SmallVector<Register, 2> DotReg;
    // unsigned NumElements = 0;
    // for (unsigned i = 0; i < Ext1UnmergeReg.size(); i++) {
    //   LLT ZeroesLLT;
    //   // Check if it is 16 or 8 elements. Set Zeroes to the according size
    //   if (MRI.getType(Ext1UnmergeReg[i]).getNumElements() == 16) {
    //     ZeroesLLT = LLT::fixed_vector(4, 32);
    //     NumElements += 4;
    //   } else {
    //     ZeroesLLT = LLT::fixed_vector(2, 32);
    //     NumElements += 2;
    //   }
    //   auto Zeroes = Builder.buildConstant(ZeroesLLT, 0)->getOperand(0).getReg();
    //   DotReg.push_back(
    //       Builder
    //           .buildInstr(DotOpcode, {MRI.getType(Zeroes)},
    //                       {Zeroes, Ext1UnmergeReg[i], Ext2UnmergeReg[i]})
    //           .getReg(0));
    // }

    // // Merge the output
    // auto ConcatMI =
    //     Builder.buildConcatVectors(LLT::fixed_vector(NumElements, 32), DotReg);

    // // Put it through a vector reduction
    // Builder.buildVecReduceAdd(MI.getOperand(0).getReg(),
    //                           ConcatMI->getOperand(0).getReg());
  }

  // Erase the dead instructions
  MI.eraseFromParent();
}

#define GET_GICOMBINER_TYPES
#include "RISCVGenPreLegalizeGICombiner.inc"
#undef GET_GICOMBINER_TYPES

class RISCVPreLegalizerCombinerImpl : public Combiner {
protected:
  // TODO: Make CombinerHelper methods const.
  mutable CombinerHelper Helper;
  const RISCVPreLegalizerCombinerImplRuleConfig &RuleConfig;
  const RISCVSubtarget &STI;

public:
  RISCVPreLegalizerCombinerImpl(
      MachineFunction &MF, CombinerInfo &CInfo, const TargetPassConfig *TPC,
      GISelKnownBits &KB, GISelCSEInfo *CSEInfo,
      const RISCVPreLegalizerCombinerImplRuleConfig &RuleConfig,
      const RISCVSubtarget &STI, MachineDominatorTree *MDT,
      const LegalizerInfo *LI);

  static const char *getName() { return "RISCV00PreLegalizerCombiner"; }

  bool tryCombineAll(MachineInstr &I) const override;

private:
#define GET_GICOMBINER_CLASS_MEMBERS
#include "RISCVGenPreLegalizeGICombiner.inc"
#undef GET_GICOMBINER_CLASS_MEMBERS
};

#define GET_GICOMBINER_IMPL
#include "RISCVGenPreLegalizeGICombiner.inc"
#undef GET_GICOMBINER_IMPL

RISCVPreLegalizerCombinerImpl::RISCVPreLegalizerCombinerImpl(
    MachineFunction &MF, CombinerInfo &CInfo, const TargetPassConfig *TPC,
    GISelKnownBits &KB, GISelCSEInfo *CSEInfo,
    const RISCVPreLegalizerCombinerImplRuleConfig &RuleConfig,
    const RISCVSubtarget &STI, MachineDominatorTree *MDT,
    const LegalizerInfo *LI)
    : Combiner(MF, CInfo, TPC, &KB, CSEInfo),
      Helper(Observer, B, /*IsPreLegalize*/ true, &KB, MDT, LI),
      RuleConfig(RuleConfig), STI(STI),
#define GET_GICOMBINER_CONSTRUCTOR_INITS
#include "RISCVGenPreLegalizeGICombiner.inc"
#undef GET_GICOMBINER_CONSTRUCTOR_INITS
{
}

// Pass boilerplate
// ================

class RISCVPreLegalizerCombiner : public MachineFunctionPass {
public:
  static char ID;

  RISCVPreLegalizerCombiner();

  StringRef getPassName() const override { return "RISCVPreLegalizerCombiner"; }

  bool runOnMachineFunction(MachineFunction &MF) override;

  void getAnalysisUsage(AnalysisUsage &AU) const override;

private:
  RISCVPreLegalizerCombinerImplRuleConfig RuleConfig;
};
} // end anonymous namespace

void RISCVPreLegalizerCombiner::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<TargetPassConfig>();
  AU.setPreservesCFG();
  getSelectionDAGFallbackAnalysisUsage(AU);
  AU.addRequired<GISelKnownBitsAnalysis>();
  AU.addPreserved<GISelKnownBitsAnalysis>();
  AU.addRequired<MachineDominatorTree>();
  AU.addPreserved<MachineDominatorTree>();
  AU.addRequired<GISelCSEAnalysisWrapperPass>();
  AU.addPreserved<GISelCSEAnalysisWrapperPass>();
  MachineFunctionPass::getAnalysisUsage(AU);
}

RISCVPreLegalizerCombiner::RISCVPreLegalizerCombiner()
    : MachineFunctionPass(ID) {
  initializeRISCVPreLegalizerCombinerPass(*PassRegistry::getPassRegistry());

  if (!RuleConfig.parseCommandLineOption())
    report_fatal_error("Invalid rule identifier");
}

bool RISCVPreLegalizerCombiner::runOnMachineFunction(MachineFunction &MF) {
  if (MF.getProperties().hasProperty(
          MachineFunctionProperties::Property::FailedISel))
    return false;
  auto &TPC = getAnalysis<TargetPassConfig>();

  // Enable CSE.
  GISelCSEAnalysisWrapper &Wrapper =
      getAnalysis<GISelCSEAnalysisWrapperPass>().getCSEWrapper();
  auto *CSEInfo = &Wrapper.get(TPC.getCSEConfig());

  const RISCVSubtarget &ST = MF.getSubtarget<RISCVSubtarget>();
  const auto *LI = ST.getLegalizerInfo();

  const Function &F = MF.getFunction();
  bool EnableOpt =
      MF.getTarget().getOptLevel() != CodeGenOptLevel::None && !skipFunction(F);
  GISelKnownBits *KB = &getAnalysis<GISelKnownBitsAnalysis>().get(MF);
  MachineDominatorTree *MDT = &getAnalysis<MachineDominatorTree>();
  CombinerInfo CInfo(/*AllowIllegalOps*/ true, /*ShouldLegalizeIllegal*/ false,
                     /*LegalizerInfo*/ nullptr, EnableOpt, F.hasOptSize(),
                     F.hasMinSize());
  RISCVPreLegalizerCombinerImpl Impl(MF, CInfo, &TPC, *KB, CSEInfo, RuleConfig,
                                     ST, MDT, LI);
  return Impl.combineMachineInstrs();
}

char RISCVPreLegalizerCombiner::ID = 0;
INITIALIZE_PASS_BEGIN(RISCVPreLegalizerCombiner, DEBUG_TYPE,
                      "Combine RISC-V machine instrs before legalization", false,
                      false)
INITIALIZE_PASS_DEPENDENCY(TargetPassConfig)
INITIALIZE_PASS_DEPENDENCY(GISelKnownBitsAnalysis)
INITIALIZE_PASS_DEPENDENCY(GISelCSEAnalysisWrapperPass)
INITIALIZE_PASS_END(RISCVPreLegalizerCombiner, DEBUG_TYPE,
                    "Combine RISC-V machine instrs before legalization", false,
                    false)

namespace llvm {
FunctionPass *createRISCVPreLegalizerCombiner() {
  return new RISCVPreLegalizerCombiner();
}
} // end namespace llvm
