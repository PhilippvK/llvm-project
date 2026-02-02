; RUN: llc -mtriple=riscv32 -mattr=+xrvc %s -o - | FileCheck --check-prefix CHECK-XRVC %s

define void @test() {
; CHECK-XRVC: .attribute 5, "rv32i2p1_xrvc1p0"
  ret void
}

