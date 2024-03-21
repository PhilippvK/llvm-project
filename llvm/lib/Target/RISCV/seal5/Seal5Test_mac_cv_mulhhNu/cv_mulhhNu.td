let Predicates = [HasVendorSeal5TestmaccvmulhhNu] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def cv_mulhhNu_ : RVInst_cv_mulhhNu<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

def : Pat<
	(i32 (i32 (srl (mul (and (i32 (srl GPR:$rs2, (i32 16))), (i32 65535)), (and (i32 (srl GPR:$rs1, (i32 16))), (i32 65535))), (and (i32 uimm5:$Is3), (i32 31))))),
	(cv_mulhhNu_ GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

}

