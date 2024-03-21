let Predicates = [HasVendorSeal5Testalucvexths] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def cv_exths_ : RVInst_cv_exths<(outs GPR:$rd), (ins GPR:$rs1)>;

def : Pat<
	(i32 (i32 (sra (i32 (shl GPR:$rs1, (i32 16))), (i32 16)))),
	(cv_exths_ GPR:$rs1)>;

}

