let Predicates = [HasVendorXCoreVAlu, IsRV32] in {

let hasSideEffects = 0, mayLoad = 1, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SEAL5_CV_ABS_ : RVInst_SEAL5_CV_ABS<(outs GPR:$rd), (ins GPR:$rs1)>;

def : Pat<
	(i32 (xor (add GPR:$rs1, (i32 (sra (i32 GPR:$rs1), (i32 (i32 31))))), (i32 (sra (i32 GPR:$rs1), (i32 (i32 31)))))),
	(SEAL5_CV_ABS_ GPR:$rs1)>;

}

