let Predicates = [HasVendorSeal5Testmaccvmsusi16] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def cv_msus_i16_ : RVInst_cv_msus_i16<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (sub (mul (i32 (sra (i32 (shl GPR:$rs2, (i32 16))), (i32 16))), (i32 (sra (i32 (shl GPR:$rs1, (i32 16))), (i32 16)))), GPR:$rd)),
	(cv_msus_i16_ GPR:$rd, GPR:$rs1, GPR:$rs2)>;

}

