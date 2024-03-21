let Predicates = [HasVendorSeal5TestalucvaddNrui16] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def GEN_cv_addNru_i16_ : RVInst_GEN_cv_addNru_i16<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (i32 (srl (add GPR:$rd, (and GPR:$rs1, (i32 65535))), (and GPR:$rs2, (i32 31))))),
	(GEN_cv_addNru_i16_ GPR:$rd, GPR:$rs1, GPR:$rs2)>;

}

