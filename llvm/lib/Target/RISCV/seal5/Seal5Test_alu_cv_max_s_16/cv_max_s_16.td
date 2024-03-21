let Predicates = [HasVendorSeal5Testalucvmaxs16] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def cv_max_s_16_ : RVInst_cv_max_s_16<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (i32 (sra (i32 (shl (select (i32 (setcc (i32 (i32 (sra (i32 (shl GPR:$rs1, (i32 16))), (i32 16)))), (i32 (i32 (sra (i32 (shl GPR:$rs2, (i32 16))), (i32 16)))), SETGT)), GPR:$rs1, GPR:$rs2), (i32 16))), (i32 16)))),
	(cv_max_s_16_ GPR:$rs1, GPR:$rs2)>;

}

