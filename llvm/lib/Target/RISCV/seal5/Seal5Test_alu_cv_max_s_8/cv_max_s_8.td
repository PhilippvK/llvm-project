let Predicates = [HasVendorSeal5Testalucvmaxs8] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def cv_max_s_8_ : RVInst_cv_max_s_8<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (i32 (sra (i32 (shl (select (i32 (setcc (i32 (i32 (sra (i32 (shl GPR:$rs1, (i32 24))), (i32 24)))), (i32 (i32 (sra (i32 (shl GPR:$rs2, (i32 24))), (i32 24)))), SETGT)), GPR:$rs1, GPR:$rs2), (i32 24))), (i32 24)))),
	(cv_max_s_8_ GPR:$rs1, GPR:$rs2)>;

}

