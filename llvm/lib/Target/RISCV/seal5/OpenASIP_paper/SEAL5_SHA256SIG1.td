let Predicates = [HasVendorXOpenASIPpaper, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SEAL5_SHA256SIG1_ : RVInst_SEAL5_SHA256SIG1<(outs GPR:$rd), (ins GPR:$rs1)>;

def : Pat<
	(i32 (xor (xor (or (i32 (shl (i32 GPR:$rs1), (i32 (i32 15)))), (i32 (srl (i32 GPR:$rs1), (i32 (i32 17))))), (or (i32 (shl (i32 GPR:$rs1), (i32 (i32 13)))), (i32 (srl (i32 GPR:$rs1), (i32 (i32 19)))))), (i32 (srl (i32 GPR:$rs1), (i32 (i32 10)))))),
	(SEAL5_SHA256SIG1_ GPR:$rs1)>;

}

