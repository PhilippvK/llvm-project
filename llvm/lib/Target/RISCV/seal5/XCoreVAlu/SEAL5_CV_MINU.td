let Predicates = [HasVendorXCoreVAlu, IsRV32] in {

let hasSideEffects = 0, mayLoad = 1, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SEAL5_CV_MINU_ : RVInst_SEAL5_CV_MINU<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (select (i32 (setcc (i32 GPR:$rs1), (i32 GPR:$rs2), SETULT)), GPR:$rs1, GPR:$rs2)),
	(SEAL5_CV_MINU_ GPR:$rs1, GPR:$rs2)>;

}

