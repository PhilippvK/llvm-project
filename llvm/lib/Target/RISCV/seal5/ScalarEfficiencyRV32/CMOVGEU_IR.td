let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def CMOVGEU_IR_ : RVInst_CMOVGEU_IR<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, seal5_uimm5:$uimm5)>;

def : Pat<
	(i32 (select (i32 (setcc (i32 GPR:$rd), (i32 (i32 seal5_uimm5:$uimm5)), SETULT)), GPR:$rd, GPR:$rs1)),
	(CMOVGEU_IR_ GPR:$rd, GPR:$rs1, seal5_uimm5:$uimm5)>;

}

