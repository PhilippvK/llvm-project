; RUN: llc -mtriple=riscv32 -mattr=+xscalarefficiencyrv32 %s -o - | FileCheck --check-prefix CHECK-XSCALAREFFICIENCYRV32 %s

define void @test() {
; CHECK-XSCALAREFFICIENCYRV32: .attribute 5, "rv32i2p1_xscalarefficiencyrv321p0"
  ret void
}

