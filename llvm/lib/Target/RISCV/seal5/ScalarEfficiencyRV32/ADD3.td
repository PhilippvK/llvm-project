let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def ADD3_ : RVInst_ADD3<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (add (add GPR:$rs2, GPR:$rs1), GPR:$rd)),
	(ADD3_ GPR:$rd, GPR:$rs1, GPR:$rs2)>;

}

