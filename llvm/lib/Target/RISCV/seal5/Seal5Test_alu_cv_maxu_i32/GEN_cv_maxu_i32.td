let Predicates = [HasVendorSeal5Testalucvmaxui32] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def GEN_cv_maxu_i32_ : RVInst_GEN_cv_maxu_i32<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (select (i32 (setcc (i32 GPR:$rs1), (i32 GPR:$rs2), SETUGT)), GPR:$rs1, GPR:$rs2)),
	(GEN_cv_maxu_i32_ GPR:$rs1, GPR:$rs2)>;

}

