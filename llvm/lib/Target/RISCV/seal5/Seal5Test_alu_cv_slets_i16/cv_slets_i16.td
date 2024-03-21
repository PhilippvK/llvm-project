let Predicates = [HasVendorSeal5Testalucvsletsi16] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def cv_slets_i16_ : RVInst_cv_slets_i16<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (i32 (setcc (i32 (i32 (sra (i32 (shl GPR:$rs1, (i32 16))), (i32 16)))), (i32 (i32 (sra (i32 (shl GPR:$rs2, (i32 16))), (i32 16)))), SETLE))),
	(cv_slets_i16_ GPR:$rs1, GPR:$rs2)>;

}

