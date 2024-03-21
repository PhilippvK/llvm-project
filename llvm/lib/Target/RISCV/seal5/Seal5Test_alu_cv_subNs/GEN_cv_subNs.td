let Predicates = [HasVendorSeal5TestalucvsubNs] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def GEN_cv_subNs_ : RVInst_GEN_cv_subNs<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

def : Pat<
	(i32 (i32 (sra (sub GPR:$rs1, GPR:$rs2), (and (i32 uimm5:$Is3), (i32 31))))),
	(GEN_cv_subNs_ GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

}

