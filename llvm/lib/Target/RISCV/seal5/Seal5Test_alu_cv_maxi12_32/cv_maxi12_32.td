let Predicates = [HasVendorSeal5Testalucvmaxi1232] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def cv_maxi12_32_ : RVInst_cv_maxi12_32<(outs GPR:$rd), (ins GPR:$rs1, uimm12:$imm5)>;

def : Pat<
	(i32 (select (i32 (setcc (i32 GPR:$rs1), (i32 (i32 (sra (i32 (shl (i32 uimm12:$imm5), (i32 20))), (i32 20)))), SETGT)), GPR:$rs1, (i32 (sra (i32 (shl (i32 uimm12:$imm5), (i32 20))), (i32 20))))),
	(cv_maxi12_32_ GPR:$rs1, uimm12:$imm5)>;

}

