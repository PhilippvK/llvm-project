let Predicates = [HasVendorSeal5Testalucvmaxu16] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def cv_max_u_16_ : RVInst_cv_max_u_16<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (and (select (i32 (setcc (i32 (and GPR:$rs1, (i32 65535))), (i32 (and GPR:$rs2, (i32 65535))), SETUGT)), GPR:$rs1, GPR:$rs2), (i32 65535))),
	(cv_max_u_16_ GPR:$rs1, GPR:$rs2)>;

}

