let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isBranch = 0, isTerminator = 0, isCodeGenOnly = 1, Constraints = "" in def ZEXT_UNALIGNED_BYTE_ : RVInst_ZEXT_UNALIGNED_BYTE<(outs GPR:$rd), (ins GPR:$rs1)>;

def : Pat<
	(i32 (and (i32 (srl (i32 GPR:$rs1), (i32 (i32 11)))), (i32 255))),
	(ZEXT_UNALIGNED_BYTE_ GPR:$rs1)>;

}

