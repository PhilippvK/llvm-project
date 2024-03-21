let Predicates = [HasVendorSeal5Testalucvsletui16] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def GEN_cv_sletu_i16_ : RVInst_GEN_cv_sletu_i16<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (i32 (setcc (i32 (and GPR:$rs1, (i32 65535))), (i32 (and GPR:$rs2, (i32 65535))), SETULE))),
	(GEN_cv_sletu_i16_ GPR:$rs1, GPR:$rs2)>;

}

