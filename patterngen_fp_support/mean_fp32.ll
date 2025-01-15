; ModuleID = 'mod'
source_filename = "mod"

define void @implMEAN(ptr %rs2, ptr %rs1, ptr noalias %rd) {
  br i1 true, label %1, label %9

1:                                                ; preds = %0
  %rs1.v = load i32, ptr %rs1, align 4
  %rs2.v = load i32, ptr %rs2, align 4
  %2 = bitcast i32 %rs1.v to float
  %3 = bitcast i32 %rs2.v to float
  %4 = fadd float %2, %3
  %5 = bitcast float %4 to i32
  %6 = bitcast i32 %5 to float
  %7 = fdiv float %6, 2.000000e+00
  %8 = bitcast float %7 to i32
  store i32 %8, ptr %rd, align 4
  br label %9

9:                                                ; preds = %1, %0
  ret void
}

