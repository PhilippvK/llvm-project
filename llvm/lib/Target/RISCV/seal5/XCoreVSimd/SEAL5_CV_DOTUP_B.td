let Predicates = [HasVendorXCoreVSimd, IsRV32] in {

let hasSideEffects = 0, mayLoad = 1, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SEAL5_CV_DOTUP_B_ : RVInst_SEAL5_CV_DOTUP_B<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (and (add (add (add (mul (i32 (srl GPR:$rs2, (i32 8))), (i32 (srl GPR:$rs1, (i32 8)))), (mul GPR:$rs2, GPR:$rs1)), (mul (i32 (srl GPR:$rs2, (i32 16))), (i32 (srl GPR:$rs1, (i32 16))))), (mul (i32 (srl GPR:$rs2, (i32 24))), (i32 (srl GPR:$rs1, (i32 24))))), (i32 255))),
	(SEAL5_CV_DOTUP_B_ GPR:$rs1, GPR:$rs2)>;

}

