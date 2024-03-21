let Predicates = [HasVendorSeal5Testalucvminui16] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def GEN_cv_minu_i16_ : RVInst_GEN_cv_minu_i16<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (and (select (i32 (setcc (i32 (and GPR:$rs1, (i32 65535))), (i32 (and GPR:$rs2, (i32 65535))), SETULT)), GPR:$rs1, GPR:$rs2), (i32 65535))),
	(GEN_cv_minu_i16_ GPR:$rs1, GPR:$rs2)>;

}

