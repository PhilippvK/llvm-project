let Predicates = [HasVendorSeal5TestalucvaddNu] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def GEN_cv_addNu_ : RVInst_GEN_cv_addNu<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

def : Pat<
	(i32 (i32 (srl (add GPR:$rs2, GPR:$rs1), (and (i32 uimm5:$Is3), (i32 31))))),
	(GEN_cv_addNu_ GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

}

