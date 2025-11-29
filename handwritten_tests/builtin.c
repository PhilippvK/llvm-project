int test_intrinsic(int a, int b, int c) {
    // CHECK: <test_intrinsic>
    // Can't rely upon specific registers being used but at least instruction should have been used
    // CHECK: xexample.subincacc
    c = __builtin_riscv_xscalarefficiencyrv32_xexample_slli_add_addi(a, b, -2, 31);
}
