let Predicates = [HasVendorSeal5Testalucvminu32] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def cv_min_u_32_ : RVInst_cv_min_u_32<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (select (i32 (setcc (i32 GPR:$rs1), (i32 GPR:$rs2), SETULT)), GPR:$rs1, GPR:$rs2)),
	(cv_min_u_32_ GPR:$rs1, GPR:$rs2)>;

}

