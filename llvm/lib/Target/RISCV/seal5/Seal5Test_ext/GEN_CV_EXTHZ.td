let Predicates = [HasExtSeal5Testext] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def GEN_CV_EXTHZ_ : RVInst_GEN_CV_EXTHZ<(outs GPR:$rd), (ins GPR:$rs1)>;

def : Pat<
	(i32 (and GPR:$rs1, (i32 65535))),
	(GEN_CV_EXTHZ_ GPR:$rs1)>;

}

