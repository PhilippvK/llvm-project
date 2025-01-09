let Predicates = [HasVendorXCoreVMac, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SEAL5_CV_MULUN_ : RVInst_SEAL5_CV_MULUN<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

def : Pat<
	(i32 (i32 (srl (i32 (and (mul GPR:$rs2, GPR:$rs1), (i32 65535))), (i32 (i32 uimm5:$Is3))))),
	(SEAL5_CV_MULUN_ GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

}

