let Predicates = [HasVendorSeal5Testmaccvmsuui32] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def GEN_cv_msuu_i32_ : RVInst_GEN_cv_msuu_i32<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (sub GPR:$rd, (mul (i32 (sra (i32 (shl GPR:$rs2, (i32 16))), (i32 16))), GPR:$rs1))),
	(GEN_cv_msuu_i32_ GPR:$rd, GPR:$rs1, GPR:$rs2)>;

}

