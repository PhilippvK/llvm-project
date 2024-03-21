let Predicates = [HasVendorSeal5TestmaccvmulNu] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def GEN_cv_mulNu_ : RVInst_GEN_cv_mulNu<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

def : Pat<
	(i32 (i32 (srl (mul (and GPR:$rs2, (i32 65535)), (and GPR:$rs1, (i32 65535))), (and (i32 uimm5:$Is3), (i32 31))))),
	(GEN_cv_mulNu_ GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

}

