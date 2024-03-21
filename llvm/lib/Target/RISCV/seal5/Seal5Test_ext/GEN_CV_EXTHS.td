let Predicates = [HasExtSeal5Testext] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def GEN_CV_EXTHS_ : RVInst_GEN_CV_EXTHS<(outs GPR:$rd), (ins GPR:$rs1)>;

def : Pat<
	(i32 (i32 (sra (i32 (shl GPR:$rs1, (i32 16))), (i32 16)))),
	(GEN_CV_EXTHS_ GPR:$rs1)>;

}

