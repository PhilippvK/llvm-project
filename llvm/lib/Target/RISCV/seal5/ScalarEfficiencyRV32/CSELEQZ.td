let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def CSELEQZ_ : RVInst_CSELEQZ<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (select (i32 (setcc (i32 GPR:$rd), (i32 (i32 0)), SETEQ)), GPR:$rs1, GPR:$rs2)),
	(CSELEQZ_ GPR:$rd, GPR:$rs1, GPR:$rs2)>;

}

