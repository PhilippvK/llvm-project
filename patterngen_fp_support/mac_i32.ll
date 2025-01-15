; ModuleID = 'mod'
source_filename = "mod"

define void @implMAC(ptr %rs2, ptr %rs1, ptr noalias %rd) {
  br i1 true, label %1, label %9

1:                                                ; preds = %0
  %rs1.v = load i32, ptr %rs1, align 4
  %rs2.v = load i32, ptr %rs2, align 4
  %2 = zext i32 %rs1.v to i64
  %3 = zext i32 %rs2.v to i64
  %4 = mul i64 %2, %3
  %rd.v = load i32, ptr %rd, align 4
  %5 = zext i32 %rd.v to i128
  %6 = zext i64 %4 to i128
  %7 = add i128 %5, %6
  %8 = trunc i128 %7 to i32
  store i32 %8, ptr %rd, align 4
  br label %9

9:                                                ; preds = %1, %0
  ret void
}

