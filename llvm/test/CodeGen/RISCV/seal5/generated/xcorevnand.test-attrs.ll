; RUN: llc -mtriple=riscv32 -mattr=+xcorevnand %s -o - | FileCheck --check-prefix CHECK-XCOREVNAND %s

define void @test() {
; CHECK-XCOREVNAND: .attribute 5, "rv32i2p1_xcorevnand1p0"
  ret void
}

