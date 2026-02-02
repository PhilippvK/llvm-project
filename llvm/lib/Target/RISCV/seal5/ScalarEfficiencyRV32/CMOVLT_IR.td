let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def CMOVLT_IR_ : RVInst_CMOVLT_IR<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, seal5_uimm5:$simm5)>;

def : Pat<
	(i32 (select (i32 (setcc (i32 GPR:$rd), (i32 (i32 seal5_uimm5:$simm5)), SETLT)), GPR:$rs1, GPR:$rd)),
	(CMOVLT_IR_ GPR:$rd, GPR:$rs1, seal5_uimm5:$simm5)>;

}

