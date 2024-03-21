let Predicates = [HasVendorSeal5TestmaccvmachhNu] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def cv_machhNu_ : RVInst_cv_machhNu<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

def : Pat<
	(i32 (i32 (srl (add (mul (and (i32 (srl GPR:$rs2, (i32 16))), (i32 65535)), (and (i32 (srl GPR:$rs1, (i32 16))), (i32 65535))), GPR:$rd), (and (i32 uimm5:$Is3), (i32 31))))),
	(cv_machhNu_ GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

}

