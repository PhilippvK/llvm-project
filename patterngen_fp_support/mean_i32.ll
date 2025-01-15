; ModuleID = 'mod'
source_filename = "mod"

define void @implMEAN(ptr %rs2, ptr %rs1, ptr noalias %rd) {
  br i1 true, label %1, label %4

1:                                                ; preds = %0
  %rs1.v = load i32, ptr %rs1, align 4
  %rs2.v = load i32, ptr %rs2, align 4
  %2 = add i32 %rs1.v, %rs2.v
  %3 = udiv i32 %2, 2
  store i32 %3, ptr %rd, align 4
  br label %4

4:                                                ; preds = %1, %0
  ret void
}

