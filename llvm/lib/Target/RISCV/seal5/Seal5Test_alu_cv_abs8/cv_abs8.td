let Predicates = [HasVendorSeal5Testalucvabs8] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def cv_abs8_ : RVInst_cv_abs8<(outs GPR:$rd), (ins GPR:$rs1)>;

def : Pat<
	(i32 (select (i32 (setcc (i32 (and GPR:$rs1, (i32 128))), (i32 (i32 0)), SETEQ)), (and GPR:$rs1, (i32 127)), (sub (i32 0), (i32 (sra (i32 (shl GPR:$rs1, (i32 24))), (i32 24)))))),
	(cv_abs8_ GPR:$rs1)>;

}

