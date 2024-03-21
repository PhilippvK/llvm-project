let Predicates = [HasVendorSeal5TestmaccvmacRNs] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def GEN_cv_macRNs_ : RVInst_GEN_cv_macRNs<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

def : Pat<
	(i32 (xor (add (add GPR:$rd, (i32 2)), (mul (i32 (sra (i32 (shl GPR:$rs2, (i32 16))), (i32 16))), (i32 (sra (i32 (shl GPR:$rs1, (i32 16))), (i32 16))))), (i32 (sra (i32 (shl (i32 (sra (i32 (sra (i32 (shl (add (and (i32 uimm5:$Is3), (i32 31)), (i32 -1)), (i32 24))), (i32 24))), (and (i32 uimm5:$Is3), (i32 31)))), (i32 24))), (i32 24))))),
	(GEN_cv_macRNs_ GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

}

