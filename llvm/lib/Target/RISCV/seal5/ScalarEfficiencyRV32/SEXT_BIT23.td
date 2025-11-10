let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isBranch = 0, isTerminator = 0, isCodeGenOnly = 1, Constraints = "" in def SEXT_BIT23_ : RVInst_SEXT_BIT23<(outs GPR:$rd), (ins GPR:$rs1)>;

def : Pat<
	(i32 (i32 (sra (i32 (i32 (shl (i32 GPR:$rs1), (i32 (i32 8))))), (i32 (i32 31))))),
	(SEXT_BIT23_ GPR:$rs1)>;

}

