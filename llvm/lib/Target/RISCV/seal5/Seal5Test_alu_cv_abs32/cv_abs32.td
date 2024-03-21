let Predicates = [HasVendorSeal5Testalucvabs32] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def cv_abs32_ : RVInst_cv_abs32<(outs GPR:$rd), (ins GPR:$rs1)>;

def : Pat<
	(i32 (xor (add GPR:$rs1, (i32 (sra GPR:$rs1, (i32 31)))), (i32 (sra GPR:$rs1, (i32 31))))),
	(cv_abs32_ GPR:$rs1)>;

}

