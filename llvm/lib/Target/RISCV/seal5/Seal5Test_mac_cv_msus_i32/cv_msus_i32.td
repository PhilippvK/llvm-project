let Predicates = [HasVendorSeal5Testmaccvmsusi32] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def cv_msus_i32_ : RVInst_cv_msus_i32<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (sub (mul GPR:$rs2, GPR:$rs1), GPR:$rd)),
	(cv_msus_i32_ GPR:$rd, GPR:$rs1, GPR:$rs2)>;

}

