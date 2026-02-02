let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def CMOVGEU_RI_ : RVInst_CMOVGEU_RI<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, seal5_uimm5:$imm5)>;

def : Pat<
	(i32 (select (i32 (setcc (i32 GPR:$rd), (i32 GPR:$rs1), SETULT)), GPR:$rd, (i32 seal5_uimm5:$imm5))),
	(CMOVGEU_RI_ GPR:$rd, GPR:$rs1, seal5_uimm5:$imm5)>;

}

