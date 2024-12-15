let Predicates = [HasVendorXCoreVMac, IsRV32] in {

let hasSideEffects = 0, mayLoad = 1, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def SEAL5_CV_MSU_ : RVInst_SEAL5_CV_MSU<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (sub GPR:$rd, (mul GPR:$rs2, GPR:$rs1))),
	(SEAL5_CV_MSU_ GPR:$rd, GPR:$rs1, GPR:$rs2)>;

}

