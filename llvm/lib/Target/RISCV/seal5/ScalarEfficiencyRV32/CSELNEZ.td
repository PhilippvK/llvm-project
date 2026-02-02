let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def CSELNEZ_ : RVInst_CSELNEZ<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (select (i32 (setcc (i32 GPR:$rd), (i32 (i32 0)), SETEQ)), GPR:$rs2, GPR:$rs1)),
	(CSELNEZ_ GPR:$rd, GPR:$rs1, GPR:$rs2)>;

}

