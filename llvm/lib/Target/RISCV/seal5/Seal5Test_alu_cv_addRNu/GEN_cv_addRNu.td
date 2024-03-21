let Predicates = [HasVendorSeal5TestalucvaddRNu] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def GEN_cv_addRNu_ : RVInst_GEN_cv_addRNu<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

def : Pat<
	(i32 (xor (add (add GPR:$rs1, (i32 2)), GPR:$rs2), (i32 (sra (i32 (shl (i32 (sra (i32 (sra (i32 (shl (add (and (i32 uimm5:$Is3), (i32 31)), (i32 -1)), (i32 24))), (i32 24))), (and (i32 uimm5:$Is3), (i32 31)))), (i32 24))), (i32 24))))),
	(GEN_cv_addRNu_ GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

}

