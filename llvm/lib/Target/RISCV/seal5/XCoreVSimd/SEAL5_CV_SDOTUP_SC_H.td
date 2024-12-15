let Predicates = [HasVendorXCoreVSimd, IsRV32] in {

let hasSideEffects = 0, mayLoad = 1, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def SEAL5_CV_SDOTUP_SC_H_ : RVInst_SEAL5_CV_SDOTUP_SC_H<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (add (add GPR:$rd, (and (mul GPR:$rs2, GPR:$rs1), (i32 65535))), (and (mul (i32 (srl GPR:$rs1, (i32 16))), GPR:$rs2), (i32 65535)))),
	(SEAL5_CV_SDOTUP_SC_H_ GPR:$rd, GPR:$rs1, GPR:$rs2)>;

}

