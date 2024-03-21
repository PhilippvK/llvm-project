let Predicates = [HasVendorSeal5TestalucvsubRNrui32] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def cv_subRNru_i32_ : RVInst_cv_subRNru_i32<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (xor (sub (add GPR:$rd, (i32 2)), GPR:$rs1), (i32 (sra (i32 (shl (i32 (sra (i32 (sra (i32 (shl (add (and GPR:$rs2, (i32 31)), (i32 -1)), (i32 24))), (i32 24))), (and GPR:$rs2, (i32 31)))), (i32 24))), (i32 24))))),
	(cv_subRNru_i32_ GPR:$rd, GPR:$rs1, GPR:$rs2)>;

}

