let Predicates = [HasVendorXOpenASIPpaper, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SEAL5_ROTR32_ : RVInst_SEAL5_ROTR32<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (or (i32 (shl (i32 GPR:$rs1), (i32 (i32 (sra (i32 (sub (i32 -2147483648), (and (i32 (shl (i32 GPR:$rs2), (i32 (i32 26)))), (i32 2080374784)))), (i32 (i32 26))))))), (i32 (srl (i32 GPR:$rs1), (i32 (and GPR:$rs2, (i32 31))))))),
	(SEAL5_ROTR32_ GPR:$rs1, GPR:$rs2)>;

}

