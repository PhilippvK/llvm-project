let Predicates = [HasVendorSeal5TestmaccvmacRNu] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def cv_macRNu_ : RVInst_cv_macRNu<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

def : Pat<
	(i32 (xor (add (add GPR:$rd, (i32 2)), (mul (and GPR:$rs2, (i32 65535)), (and GPR:$rs1, (i32 65535)))), (i32 (sra (i32 (shl (i32 (sra (i32 (sra (i32 (shl (add (and (i32 uimm5:$Is3), (i32 31)), (i32 -1)), (i32 24))), (i32 24))), (and (i32 uimm5:$Is3), (i32 31)))), (i32 24))), (i32 24))))),
	(cv_macRNu_ GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

}

