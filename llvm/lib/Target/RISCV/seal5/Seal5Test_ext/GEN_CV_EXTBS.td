let Predicates = [HasExtSeal5Testext] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def GEN_CV_EXTBS_ : RVInst_GEN_CV_EXTBS<(outs GPR:$rd), (ins GPR:$rs1)>;

def : Pat<
	(i32 (i32 (sra (i32 (shl GPR:$rs1, (i32 24))), (i32 24)))),
	(GEN_CV_EXTBS_ GPR:$rs1)>;

}

