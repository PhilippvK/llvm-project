let Predicates = [HasVendorXCoreVMac, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def SEAL5_CV_MAC_ : RVInst_SEAL5_CV_MAC<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (add (mul GPR:$rs2, GPR:$rs1), GPR:$rd)),
	(SEAL5_CV_MAC_ GPR:$rd, GPR:$rs1, GPR:$rs2)>;

}

