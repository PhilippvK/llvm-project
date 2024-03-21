let Predicates = [HasVendorSeal5TestmaccvmulhhNs] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def cv_mulhhNs_ : RVInst_cv_mulhhNs<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

def : Pat<
	(i32 (i32 (sra (mul (i32 (sra (i32 (shl (i32 (srl GPR:$rs2, (i32 16))), (i32 16))), (i32 16))), (i32 (sra (i32 (shl (i32 (srl GPR:$rs1, (i32 16))), (i32 16))), (i32 16)))), (and (i32 uimm5:$Is3), (i32 31))))),
	(cv_mulhhNs_ GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

}

