let Predicates = [HasVendorXCoreVSimd, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SEAL5_CV_DOTUP_SC_B_ : RVInst_SEAL5_CV_DOTUP_SC_B<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (and (mul (add (add (add (i32 (srl GPR:$rs1, (i32 8))), GPR:$rs1), (i32 (srl GPR:$rs1, (i32 16)))), (i32 (srl GPR:$rs1, (i32 24)))), GPR:$rs2), (i32 255))),
	(SEAL5_CV_DOTUP_SC_B_ GPR:$rs1, GPR:$rs2)>;

}

