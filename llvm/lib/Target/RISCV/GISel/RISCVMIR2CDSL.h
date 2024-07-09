//== llvm/lib/Target/RISCV/GISel/RISCVMIR2CDSL.h -----------------*- C++ -*-==//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
/// \file This file describes the interface of the MachineFunctionPass
/// responsible for selecting (possibly generic) machine instructions to
/// target-specific instructions.
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_RISCV_GISEL_RISCVMIR2CDSL_H
#define LLVM_LIB_TARGET_RISCV_GISEL_RISCVMIR2CDSL_H

#include "llvm/ADT/StringRef.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/Support/CodeGen.h"

namespace llvm {

class BlockFrequencyInfo;
class ProfileSummaryInfo;

class RISCVMIR2CDSL : public MachineFunctionPass {
public:
  static char ID;
  StringRef getPassName() const override { return "RISCVMIR2CDSL"; }

  void getAnalysisUsage(AnalysisUsage &AU) const override;

  MachineFunctionProperties getRequiredProperties() const override {
    return MachineFunctionProperties()
        .set(MachineFunctionProperties::Property::IsSSA);
        // .set(MachineFunctionProperties::Property::Legalized)
        // .set(MachineFunctionProperties::Property::RegBankSelected);
  }

  RISCVMIR2CDSL(CodeGenOptLevel OL);
  RISCVMIR2CDSL();

  bool runOnMachineFunction(MachineFunction &MF) override;

protected:
  BlockFrequencyInfo *BFI = nullptr;
  ProfileSummaryInfo *PSI = nullptr;

  CodeGenOptLevel OptLevel = CodeGenOptLevel::None;
};
} // End namespace llvm.

#endif
