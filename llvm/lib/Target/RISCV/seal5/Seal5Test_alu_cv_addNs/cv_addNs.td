let Predicates = [HasVendorSeal5TestalucvaddNs] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def cv_addNs_ : RVInst_cv_addNs<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

def : Pat<
	(i32 (i32 (sra (add GPR:$rs2, GPR:$rs1), (and (i32 uimm5:$Is3), (i32 31))))),
	(cv_addNs_ GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

}

