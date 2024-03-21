let Predicates = [HasVendorSeal5Testalucvextbs] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def cv_extbs_ : RVInst_cv_extbs<(outs GPR:$rd), (ins GPR:$rs1)>;

def : Pat<
	(i32 (i32 (sra (i32 (shl GPR:$rs1, (i32 24))), (i32 24)))),
	(cv_extbs_ GPR:$rs1)>;

}

