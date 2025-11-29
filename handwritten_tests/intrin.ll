declare i32 @llvm.riscv.xscalarefficiencyrv32.xexample.slli.add.addi(i32, i32, i32 immarg, i32 immarg)
declare i32 @llvm.riscv.cv.mac.muluN(i32, i32, i32)

define i32 @test(i32 %a, i32 %b, i32 %c) {
  %1 = call i32 @llvm.riscv.xscalarefficiencyrv32.xexample.slli.add.addi(i32 %a, i32 %b, i32 -2, i32 31)
  ret i32 %1
}

; define i32 @test2(i32 %a, i32 %b) {
;   %1 = call i32 @llvm.riscv.cv.mac.muluN(i32 %a, i32 %b, i32 1)
;   ret i32 %1
; }


; define i32 @test.muluN(i32 %a, i32 %b) {
; ; CHECK-LABEL: test.muluN:
; ; CHECK:       # %bb.0:
; ; CHECK-NEXT:    cv.mulun a0, a0, a1, 5
; ; CHECK-NEXT:    ret
;   %1 = call i32 @llvm.riscv.cv.mac.muluN(i32 %a, i32 %b, i32 0)
;   ret i32 %1
; }
