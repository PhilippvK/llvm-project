let Predicates = [HasVendorXCoreVMac, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SEAL5_CV_MULHHUN_ : RVInst_SEAL5_CV_MULHHUN<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

def : Pat<
	(i32 (i32 (srl (i32 (and (mul (i32 (srl GPR:$rs2, (i32 16))), (i32 (srl GPR:$rs1, (i32 16)))), (i32 65535))), (i32 (i32 uimm5:$Is3))))),
	(SEAL5_CV_MULHHUN_ GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

}

