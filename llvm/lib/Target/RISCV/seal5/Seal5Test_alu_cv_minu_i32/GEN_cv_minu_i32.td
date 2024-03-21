let Predicates = [HasVendorSeal5Testalucvminui32] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def GEN_cv_minu_i32_ : RVInst_GEN_cv_minu_i32<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (select (i32 (setcc (i32 GPR:$rs1), (i32 GPR:$rs2), SETULT)), GPR:$rs1, GPR:$rs2)),
	(GEN_cv_minu_i32_ GPR:$rs1, GPR:$rs2)>;

}

