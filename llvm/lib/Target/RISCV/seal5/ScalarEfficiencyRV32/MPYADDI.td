let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def MPYADDI_ : RVInst_MPYADDI<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, seal5_uimm5:$imm5)>;

def : Pat<
	(i32 (add GPR:$rd, (mul GPR:$rs1, (i32 seal5_uimm5:$imm5)))),
	(MPYADDI_ GPR:$rd, GPR:$rs1, seal5_uimm5:$imm5)>;

}

