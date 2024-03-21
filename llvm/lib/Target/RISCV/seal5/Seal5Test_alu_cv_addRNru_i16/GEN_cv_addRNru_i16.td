let Predicates = [HasVendorSeal5TestalucvaddRNrui16] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def GEN_cv_addRNru_i16_ : RVInst_GEN_cv_addRNru_i16<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (xor (i32 (sra (add (and GPR:$rs2, (i32 31)), (i32 -1)), (and GPR:$rs2, (i32 31)))), (add (add (and GPR:$rs1, (i32 65535)), (i32 2)), GPR:$rd))),
	(GEN_cv_addRNru_i16_ GPR:$rd, GPR:$rs1, GPR:$rs2)>;

}

