let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isBranch = 0, isTerminator = 0, isCodeGenOnly = 1, Constraints = "$rd1 = $rd1_wb, $rd2 = $rd2_wb" in def DUALADD_ : RVInst_DUALADD<(outs GPR:$rd1_wb, GPR:$rd2_wb), (ins GPR:$rd1, GPR:$rd2, GPR:$rs1)>;
}
