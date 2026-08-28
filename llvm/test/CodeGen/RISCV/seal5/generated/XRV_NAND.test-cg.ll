; RUN: llc -mtriple=riscv32 -stop-after=instruction-select -mattr=+fast-unaligned-access,+m,+xrvc %s -global-isel=1 -o - \
  ; RUN: | FileCheck -check-prefix=RV32-MIR %s
  ; RUN: llc -mtriple=riscv32 -mattr=+fast-unaligned-access,+m,+xrvc %s -global-isel=1 -o - \
  ; RUN: | FileCheck -check-prefix=RV32-ASM %s
; ModuleID = 'mod'
source_filename = "mod"
target datalayout = "e-m:e-p:32:32-i64:64-n32-S128"
target triple = "riscv32-unknown-linux-gnu"

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite)
define void @implXRV_NAND(ptr noalias nocapture writeonly initializes((0, 4)) %rd, ptr nocapture readonly %rs1, ptr nocapture readonly %rs2) local_unnamed_addr #0 {
  ; RV32-MIR-LABEL: name: implXRV_NAND
  ; RV32-MIR: XRV_NAND
  ; RV32-MIR-NEXT: SW
  ; RV32-MIR-NEXT: PseudoRET
  ; RV32-ASM-LABEL: implXRV_NAND:
  ; RV32-ASM: xrv.nand
  ; RV32-ASM-NEXT: sw
  ; RV32-ASM-NEXT: ret
  %rs1.v = load i32, ptr %rs1, align 4
  %rs2.v = load i32, ptr %rs2, align 4
  %1 = and i32 %rs2.v, %rs1.v
  %2 = xor i32 %1, -1
  store i32 %2, ptr %rd, align 4
  ret void
}

attributes #0 = { mustprogress nofree norecurse nosync nounwind willreturn memory(argmem: readwrite) }
