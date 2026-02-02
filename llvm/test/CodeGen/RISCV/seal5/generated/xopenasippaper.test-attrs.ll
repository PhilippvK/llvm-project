; RUN: llc -mtriple=riscv32 -mattr=+xopenasippaper %s -o - | FileCheck --check-prefix CHECK-XOPENASIPPAPER %s

define void @test() {
; CHECK-XOPENASIPPAPER: .attribute 5, "rv32i2p1_xopenasippaper1p0"
  ret void
}

