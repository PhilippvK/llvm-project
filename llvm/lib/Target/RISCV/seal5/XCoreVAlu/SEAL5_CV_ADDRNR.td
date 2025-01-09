let Predicates = [HasVendorXCoreVAlu, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def SEAL5_CV_ADDRNR_ : RVInst_SEAL5_CV_ADDRNR<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (i32 (sra (i32 (add (add GPR:$rs1, GPR:$rd), (and (i32 (shl (i32 (i32 1)), (i32 (and (add (and GPR:$rs2, (i32 31)), (i32 -1)), (i32 255))))), (i32 255)))), (i32 (and GPR:$rs2, (i32 31)))))),
	(SEAL5_CV_ADDRNR_ GPR:$rd, GPR:$rs1, GPR:$rs2)>;

}

