let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def CMOVNE_II_ : RVInst_CMOVNE_II<(outs GPR:$rd_wb), (ins GPR:$rd, seal5_uimm5:$imm5, seal5_uimm5:$imm5_2)>;

def : Pat<
	(i32 (select (i32 (setcc (i32 GPR:$rd), (i32 (i32 seal5_uimm5:$imm5)), SETEQ)), GPR:$rd, (i32 seal5_uimm5:$imm5_2))),
	(CMOVNE_II_ GPR:$rd, seal5_uimm5:$imm5, seal5_uimm5:$imm5_2)>;

}

