let Predicates = [HasVendorXOpenASIPpaper, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SEAL5_AES283XOR_ : RVInst_SEAL5_AES283XOR<(outs GPR:$rd), (ins GPR:$rs1)>;

def : Pat<
	(i32 (select (i32 (setcc (i32 (and GPR:$rs1, (i32 -128))), (i32 (i32 128)), SETEQ)), (xor (i32 (shl (i32 GPR:$rs1), (i32 (i32 1)))), (i32 283)), (i32 (shl (i32 GPR:$rs1), (i32 (i32 1)))))),
	(SEAL5_AES283XOR_ GPR:$rs1)>;

}

