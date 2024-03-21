let Predicates = [HasVendorSeal5Testalucvminsi16] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def GEN_cv_mins_i16_ : RVInst_GEN_cv_mins_i16<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (i32 (sra (i32 (shl (select (i32 (setcc (i32 (i32 (sra (i32 (shl GPR:$rs1, (i32 16))), (i32 16)))), (i32 (i32 (sra (i32 (shl GPR:$rs2, (i32 16))), (i32 16)))), SETLT)), GPR:$rs1, GPR:$rs2), (i32 16))), (i32 16)))),
	(GEN_cv_mins_i16_ GPR:$rs1, GPR:$rs2)>;

}

