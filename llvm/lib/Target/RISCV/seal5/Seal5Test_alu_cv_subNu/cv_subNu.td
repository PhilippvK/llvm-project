let Predicates = [HasVendorSeal5TestalucvsubNu] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def cv_subNu_ : RVInst_cv_subNu<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

def : Pat<
	(i32 (i32 (sra (sub GPR:$rs1, GPR:$rs2), (and (i32 uimm5:$Is3), (i32 31))))),
	(cv_subNu_ GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

}

