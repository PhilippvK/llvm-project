let Predicates = [HasVendorXCoreVSimd, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SEAL5_CV_DOTUP_SC_H_ : RVInst_SEAL5_CV_DOTUP_SC_H<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (and (mul (add (i32 (srl GPR:$rs1, (i32 16))), GPR:$rs1), GPR:$rs2), (i32 65535))),
	(SEAL5_CV_DOTUP_SC_H_ GPR:$rs1, GPR:$rs2)>;

}

