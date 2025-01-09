let Predicates = [HasVendorXCoreVSimd, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SEAL5_CV_DOTSP_B_ : RVInst_SEAL5_CV_DOTSP_B<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (i32 (sra (i32 (i32 (shl (i32 (add (add (add (mul (i32 (srl GPR:$rs2, (i32 8))), (i32 (srl GPR:$rs1, (i32 8)))), (mul GPR:$rs2, GPR:$rs1)), (mul (i32 (srl GPR:$rs2, (i32 16))), (i32 (srl GPR:$rs1, (i32 16))))), (mul (i32 (srl GPR:$rs2, (i32 24))), (i32 (srl GPR:$rs1, (i32 24)))))), (i32 (i32 24))))), (i32 (i32 24))))),
	(SEAL5_CV_DOTSP_B_ GPR:$rs1, GPR:$rs2)>;

}

