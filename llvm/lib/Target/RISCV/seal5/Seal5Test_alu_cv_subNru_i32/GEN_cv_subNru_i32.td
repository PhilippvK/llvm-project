let Predicates = [HasVendorSeal5TestalucvsubNrui32] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def GEN_cv_subNru_i32_ : RVInst_GEN_cv_subNru_i32<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (i32 (sra (sub GPR:$rd, GPR:$rs1), (and GPR:$rs2, (i32 31))))),
	(GEN_cv_subNru_i32_ GPR:$rd, GPR:$rs1, GPR:$rs2)>;

}

