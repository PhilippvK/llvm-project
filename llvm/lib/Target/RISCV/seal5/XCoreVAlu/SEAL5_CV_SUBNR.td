let Predicates = [HasVendorXCoreVAlu, IsRV32] in {

let hasSideEffects = 0, mayLoad = 1, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def SEAL5_CV_SUBNR_ : RVInst_SEAL5_CV_SUBNR<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (i32 (sra (i32 (sub GPR:$rd, GPR:$rs1)), (i32 (and GPR:$rs2, (i32 31)))))),
	(SEAL5_CV_SUBNR_ GPR:$rd, GPR:$rs1, GPR:$rs2)>;

}

