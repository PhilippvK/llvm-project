let Predicates = [HasVendorXOpenASIPpaper, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SEAL5_SHA256SIG0B_ : RVInst_SEAL5_SHA256SIG0B<(outs GPR:$rd), (ins GPR:$rs1)>;

def : Pat<
	(i32 (xor (xor (or (i32 (shl (i32 GPR:$rs1), (i32 (i32 25)))), (i32 (srl (i32 GPR:$rs1), (i32 (i32 7))))), (or (i32 (shl (i32 GPR:$rs1), (i32 (i32 14)))), (i32 (srl (i32 GPR:$rs1), (i32 (i32 18)))))), (i32 (srl (i32 GPR:$rs1), (i32 (i32 3)))))),
	(SEAL5_SHA256SIG0B_ GPR:$rs1)>;

}

