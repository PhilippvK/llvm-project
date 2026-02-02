let Predicates = [HasStdExtXExample, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SLLI_ADD_ADDI_ : RVInst_SLLI_ADD_ADDI<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, seal5_uimm5:$imm2, seal5_simm3:$imm)>;

def : Pat<
	(i32 (add (add (i32 (shl (i32 GPR:$rs2), (i32 (i32 seal5_simm3:$imm)))), (i32 seal5_uimm5:$imm2)), GPR:$rs1)),
	(SLLI_ADD_ADDI_ GPR:$rs1, GPR:$rs2, seal5_uimm5:$imm2, seal5_simm3:$imm)>;

}

