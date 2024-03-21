let Predicates = [HasVendorSeal5TestalucvaddNrsi32] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def cv_addNrs_i32_ : RVInst_cv_addNrs_i32<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (i32 (sra (add GPR:$rs1, GPR:$rd), (and GPR:$rs2, (i32 31))))),
	(cv_addNrs_i32_ GPR:$rd, GPR:$rs1, GPR:$rs2)>;

}

