let Predicates = [HasVendorSeal5TestmaccvmacNs] in {
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def GEN_cv_macNs_ : RVInst_GEN_cv_macNs<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

def : Pat<
	(i32 (i32 (sra (add (mul (i32 (sra (i32 (shl GPR:$rs2, (i32 16))), (i32 16))), (i32 (sra (i32 (shl GPR:$rs1, (i32 16))), (i32 16)))), GPR:$rd), (and (i32 uimm5:$Is3), (i32 31))))),
	(GEN_cv_macNs_ GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

}

