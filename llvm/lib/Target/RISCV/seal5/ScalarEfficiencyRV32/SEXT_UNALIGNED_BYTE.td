let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isBranch = 0, isTerminator = 0, isCodeGenOnly = 1, Constraints = "" in def SEXT_UNALIGNED_BYTE_ : RVInst_SEXT_UNALIGNED_BYTE<(outs GPR:$rd), (ins GPR:$rs1)>;

def : Pat<
	(i32 (i32 (sra (i32 (i32 (shl (i32 GPR:$rs1), (i32 (i32 13))))), (i32 (i32 24))))),
	(SEXT_UNALIGNED_BYTE_ GPR:$rs1)>;

}

