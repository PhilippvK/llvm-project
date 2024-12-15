let Predicates = [HasVendorXCoreVBitmanip, IsRV32] in {

let hasSideEffects = 0, mayLoad = 1, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SEAL5_CV_EXTRACTUR_ : RVInst_SEAL5_CV_EXTRACTUR<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (and (i32 (srl (i32 GPR:$rs1), (i32 (and GPR:$rs2, (i32 31))))), (i32 (sra (i32 (i32 (shl (i32 (add (i32 (shl (i32 (i32 2)), (i32 (and (i32 (srl (i32 GPR:$rs2), (i32 (i32 5)))), (i32 31))))), (i32 -1))), (i32 (i32 24))))), (i32 (i32 24)))))),
	(SEAL5_CV_EXTRACTUR_ GPR:$rs1, GPR:$rs2)>;

}

