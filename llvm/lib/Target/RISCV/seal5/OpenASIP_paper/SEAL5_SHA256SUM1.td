let Predicates = [HasVendorXOpenASIPpaper, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SEAL5_SHA256SUM1_ : RVInst_SEAL5_SHA256SUM1<(outs GPR:$rd), (ins GPR:$rs1)>;

def : Pat<
	(i32 (xor (xor (or (i32 (shl (i32 GPR:$rs1), (i32 (i32 26)))), (i32 (srl (i32 GPR:$rs1), (i32 (i32 6))))), (or (i32 (shl (i32 GPR:$rs1), (i32 (i32 21)))), (i32 (srl (i32 GPR:$rs1), (i32 (i32 11)))))), (or (i32 (shl (i32 GPR:$rs1), (i32 (i32 7)))), (i32 (srl (i32 GPR:$rs1), (i32 (i32 25))))))),
	(SEAL5_SHA256SUM1_ GPR:$rs1)>;

}

