let Predicates = [HasVendorSeal5Testalucvexthz] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def cv_exthz_ : RVInst_cv_exthz<(outs GPR:$rd), (ins GPR:$rs1)>;

def : Pat<
	(i32 (and GPR:$rs1, (i32 65535))),
	(cv_exthz_ GPR:$rs1)>;

}

