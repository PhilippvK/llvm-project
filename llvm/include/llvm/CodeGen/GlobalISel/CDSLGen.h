//== llvm/CodeGen/GlobalISel/CDSLGen.h -----------------*- C++ -*-==//
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

#ifndef LLVM_CODEGEN_GLOBALISEL_CDSLGEN_H
#define LLVM_CODEGEN_GLOBALISEL_CDSLGEN_H

#include "llvm/Support/CodeGen.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"

namespace llvm {

void runCDSLGenPipeline(MachineRegisterInfo &MRI, MachineInstr &Cur, MachineFunction &Func);

} // End namespace llvm.

#endif
