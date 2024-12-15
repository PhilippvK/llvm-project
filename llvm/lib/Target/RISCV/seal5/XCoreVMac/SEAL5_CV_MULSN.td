let Predicates = [HasVendorXCoreVMac, IsRV32] in {

let hasSideEffects = 0, mayLoad = 1, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SEAL5_CV_MULSN_ : RVInst_SEAL5_CV_MULSN<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

def : Pat<
	(i32 (i32 (sra (i32 (i32 (sra (i32 (i32 (shl (i32 (mul GPR:$rs2, GPR:$rs1)), (i32 (i32 16))))), (i32 (i32 16))))), (i32 (i32 uimm5:$Is3))))),
	(SEAL5_CV_MULSN_ GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

}

