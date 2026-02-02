let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def CMOVGE_IR_ : RVInst_CMOVGE_IR<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, uimm5:$simm5)>;

def : Pat<
	(i32 (select (i32 (setcc (i32 GPR:$rd), (i32 (i32 uimm5:$simm5)), SETLT)), GPR:$rd, GPR:$rs1)),
	(CMOVGE_IR_ GPR:$rd, GPR:$rs1, uimm5:$simm5)>;

}

