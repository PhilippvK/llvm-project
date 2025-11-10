let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isBranch = 0, isTerminator = 0, isCodeGenOnly = 1, Constraints = "" in def ZEXT_BIT23_ : RVInst_ZEXT_BIT23<(outs GPR:$rd), (ins GPR:$rs1)>;

def : Pat<
	(i32 (and (i32 (srl (i32 GPR:$rs1), (i32 (i32 23)))), (i32 1))),
	(ZEXT_BIT23_ GPR:$rs1)>;

}

