let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def CMOVGE_ : RVInst_CMOVGE<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (select (i32 (setcc (i32 GPR:$rd), (i32 GPR:$rs1), SETLT)), GPR:$rd, GPR:$rs2)),
	(CMOVGE_ GPR:$rd, GPR:$rs1, GPR:$rs2)>;

}

