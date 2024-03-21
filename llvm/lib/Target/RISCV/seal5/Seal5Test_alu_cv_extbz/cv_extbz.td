let Predicates = [HasVendorSeal5Testalucvextbz] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def cv_extbz_ : RVInst_cv_extbz<(outs GPR:$rd), (ins GPR:$rs1)>;

def : Pat<
	(i32 (and GPR:$rs1, (i32 255))),
	(cv_extbz_ GPR:$rs1)>;

}

