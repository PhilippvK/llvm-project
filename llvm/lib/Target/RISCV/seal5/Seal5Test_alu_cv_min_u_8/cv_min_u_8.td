let Predicates = [HasVendorSeal5Testalucvminu8] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def cv_min_u_8_ : RVInst_cv_min_u_8<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (and (select (i32 (setcc (i32 (and GPR:$rs1, (i32 255))), (i32 (and GPR:$rs2, (i32 255))), SETULT)), GPR:$rs1, GPR:$rs2), (i32 255))),
	(cv_min_u_8_ GPR:$rs1, GPR:$rs2)>;

}

