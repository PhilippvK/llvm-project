let Predicates = [HasVendorSeal5Testalucvabs16] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def cv_abs16_ : RVInst_cv_abs16<(outs GPR:$rd), (ins GPR:$rs1)>;

def : Pat<
	(i32 (select (i32 (setcc (i32 (and (and GPR:$rs1, (i32 65535)), (i32 32768))), (i32 (i32 0)), SETEQ)), (and GPR:$rs1, (i32 65535)), (sub (i32 0), (i32 (sra (i32 (shl (and GPR:$rs1, (i32 65535)), (i32 16))), (i32 16)))))),
	(cv_abs16_ GPR:$rs1)>;

}

