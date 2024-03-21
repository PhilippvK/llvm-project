let Predicates = [HasExtSeal5Testext] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def GEN_CV_EXTBZ_ : RVInst_GEN_CV_EXTBZ<(outs GPR:$rd), (ins GPR:$rs1)>;

def : Pat<
	(i32 (and GPR:$rs1, (i32 255))),
	(GEN_CV_EXTBZ_ GPR:$rs1)>;

}

