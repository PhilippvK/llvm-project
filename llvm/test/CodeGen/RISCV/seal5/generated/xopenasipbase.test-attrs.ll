; RUN: llc -mtriple=riscv32 -mattr=+experimental-xopenasipbase %s -o - | FileCheck --check-prefix CHECK-XOPENASIPBASE %s

define void @test() {
; CHECK-XOPENASIPBASE: .attribute 5, "rv32i2p1_xopenasipbase1p0"
  ret void
}

