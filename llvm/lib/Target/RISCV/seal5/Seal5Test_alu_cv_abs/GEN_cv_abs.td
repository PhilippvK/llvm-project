let Predicates = [HasVendorSeal5Testalucvabs] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def GEN_cv_abs_ : RVInst_GEN_cv_abs<(outs GPR:$rd), (ins GPR:$rs1)>;

def : Pat<
	(i32 (xor (add GPR:$rs1, (i32 (sra GPR:$rs1, (i32 31)))), (i32 (sra GPR:$rs1, (i32 31))))),
	(GEN_cv_abs_ GPR:$rs1)>;

}

