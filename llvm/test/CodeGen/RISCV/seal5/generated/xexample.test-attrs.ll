; RUN: llc -mtriple=riscv32 -mattr=+xexample %s -o - | FileCheck --check-prefix CHECK-XEXAMPLE %s

define void @test() {
; CHECK-XEXAMPLE: .attribute 5, "rv32i2p1_xexample1p0"
  ret void
}

