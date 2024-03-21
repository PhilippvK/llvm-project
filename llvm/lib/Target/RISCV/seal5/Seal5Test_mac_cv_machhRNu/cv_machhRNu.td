let Predicates = [HasVendorSeal5TestmaccvmachhRNu] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def cv_machhRNu_ : RVInst_cv_machhRNu<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

def : Pat<
	(i32 (xor (add (add GPR:$rd, (i32 2)), (mul (and (i32 (srl GPR:$rs2, (i32 16))), (i32 65535)), (and (i32 (srl GPR:$rs1, (i32 16))), (i32 65535)))), (i32 (sra (i32 (shl (i32 (sra (i32 (sra (i32 (shl (add (and (i32 uimm5:$Is3), (i32 31)), (i32 -1)), (i32 24))), (i32 24))), (and (i32 uimm5:$Is3), (i32 31)))), (i32 24))), (i32 24))))),
	(cv_machhRNu_ GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

}

