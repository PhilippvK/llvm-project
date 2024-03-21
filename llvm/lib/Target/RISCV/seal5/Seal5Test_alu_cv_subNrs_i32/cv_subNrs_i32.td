let Predicates = [HasVendorSeal5TestalucvsubNrsi32] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def cv_subNrs_i32_ : RVInst_cv_subNrs_i32<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (i32 (sra (sub GPR:$rd, GPR:$rs1), (and GPR:$rs2, (i32 31))))),
	(cv_subNrs_i32_ GPR:$rd, GPR:$rs1, GPR:$rs2)>;

}

