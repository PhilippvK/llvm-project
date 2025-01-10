define i32 @add_positive_low_bound_reject(i32 %a) nounwind {
  %1 = add i32 %a, 2047
  ret i32 %1
}
