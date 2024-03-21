let Predicates = [HasVendorSeal5TestmaccvmulNs] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def cv_mulNs_ : RVInst_cv_mulNs<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

def : Pat<
	(i32 (i32 (sra (mul (i32 (sra (i32 (shl GPR:$rs2, (i32 16))), (i32 16))), (i32 (sra (i32 (shl GPR:$rs1, (i32 16))), (i32 16)))), (and (i32 uimm5:$Is3), (i32 31))))),
	(cv_mulNs_ GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

}

