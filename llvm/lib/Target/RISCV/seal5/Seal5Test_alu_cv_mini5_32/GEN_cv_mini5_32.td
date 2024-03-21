let Predicates = [HasVendorSeal5Testalucvmini532] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def GEN_cv_mini5_32_ : RVInst_GEN_cv_mini5_32<(outs GPR:$rd), (ins GPR:$rs1, uimm5:$imm5)>;

def : Pat<
	(i32 (select (i32 (setcc (i32 GPR:$rs1), (i32 (i32 (sra (i32 (shl (i32 uimm5:$imm5), (i32 27))), (i32 27)))), SETLT)), GPR:$rs1, (i32 (sra (i32 (shl (i32 uimm5:$imm5), (i32 27))), (i32 27))))),
	(GEN_cv_mini5_32_ GPR:$rs1, uimm5:$imm5)>;

}

