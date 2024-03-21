let Predicates = [HasVendorSeal5Testalucvmini516] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def GEN_cv_mini5_16_ : RVInst_GEN_cv_mini5_16<(outs GPR:$rd), (ins GPR:$rs1, uimm5:$imm5)>;

def : Pat<
	(i32 (i32 (sra (i32 (shl (select (i32 (setcc (i32 (i32 (sra (i32 (shl GPR:$rs1, (i32 16))), (i32 16)))), (i32 (i32 (sra (i32 (shl (i32 uimm5:$imm5), (i32 27))), (i32 27)))), SETLT)), GPR:$rs1, (i32 (sra (i32 (shl (i32 uimm5:$imm5), (i32 27))), (i32 27)))), (i32 16))), (i32 16)))),
	(GEN_cv_mini5_16_ GPR:$rs1, uimm5:$imm5)>;

}

