//=- RISCVCombine.td - Define RISC-V Combine Rules -----------*- tablegen -*-=//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
//
//===----------------------------------------------------------------------===//

include "llvm/Target/GlobalISel/Combine.td"

// Boolean: 0 = G_ZEXT, 1 = G_SEXT
def ext_addv_to_udot_addv_matchinfo : GIDefMatchData<"std::tuple<Register, Register, bool>">;

// let Predicates = [HasDotProd] in {
def ext_addv_to_udot_addv : GICombineRule<
  (defs root:$root, ext_addv_to_udot_addv_matchinfo:$matchinfo),
  (match (wip_match_opcode G_VECREDUCE_ADD):$root,
         [{ return matchExtAddvToUdotAddv(*${root}, MRI, STI, ${matchinfo}); }]),
  (apply [{ applyExtAddvToUdotAddv(*${root}, MRI, B, Observer, STI, ${matchinfo}); }])
>;
// }

def RISCVPreLegalizerCombiner: GICombiner<
  "RISCVPreLegalizerCombinerImpl", [all_combines, ext_addv_to_udot_addv]> {
}

def RISCVO0PreLegalizerCombiner: GICombiner<
  "RISCVO0PreLegalizerCombinerImpl", [optnone_combines]> {
}

// Post-legalization combines which are primarily optimizations.
// TODO: Add more combines.
def RISCVPostLegalizerCombiner
    : GICombiner<"RISCVPostLegalizerCombinerImpl",
                 [redundant_and, identity_combines]> {
}
