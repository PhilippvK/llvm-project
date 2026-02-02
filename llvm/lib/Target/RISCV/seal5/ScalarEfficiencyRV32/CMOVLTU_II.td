let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def CMOVLTU_II_ : RVInst_CMOVLTU_II<(outs GPR:$rd_wb), (ins GPR:$rd, uimm5:$imm5_2, uimm5:$uimm5)>;

def : Pat<
	(i32 (select (i32 (setcc (i32 GPR:$rd), (i32 (i32 uimm5:$uimm5)), SETULT)), (i32 uimm5:$imm5_2), GPR:$rd)),
	(CMOVLTU_II_ GPR:$rd, uimm5:$imm5_2, uimm5:$uimm5)>;

}

