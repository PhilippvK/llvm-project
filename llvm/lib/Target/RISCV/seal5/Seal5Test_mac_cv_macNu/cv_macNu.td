let Predicates = [HasVendorSeal5TestmaccvmacNu] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def cv_macNu_ : RVInst_cv_macNu<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

def : Pat<
	(i32 (i32 (srl (add (mul (and GPR:$rs2, (i32 65535)), (and GPR:$rs1, (i32 65535))), GPR:$rd), (and (i32 uimm5:$Is3), (i32 31))))),
	(cv_macNu_ GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

}

