let Predicates = [HasVendorSeal5Testmaccvmsuui16] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def GEN_cv_msuu_i16_ : RVInst_GEN_cv_msuu_i16<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (sub GPR:$rd, (mul (i32 (sra (i32 (shl GPR:$rs2, (i32 16))), (i32 16))), (and GPR:$rs1, (i32 65535))))),
	(GEN_cv_msuu_i16_ GPR:$rd, GPR:$rs1, GPR:$rs2)>;

}

