let Predicates = [HasVendorXCoreVBitmanip, IsRV32] in {

let hasSideEffects = 0, mayLoad = 1, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SEAL5_CV_CNT_ : RVInst_SEAL5_CV_CNT<(outs GPR:$rd), (ins GPR:$rs1)>;

def : Pat<
	(i32 (i32 (srl (i32 (mul (and (add (i32 (srl (i32 (add (and (i32 (srl (i32 (sub GPR:$rs1, (and (i32 (srl (i32 GPR:$rs1), (i32 (i32 1)))), (i32 1431655765)))), (i32 (i32 2)))), (i32 858993459)), (and (sub GPR:$rs1, (and (i32 (srl (i32 GPR:$rs1), (i32 (i32 1)))), (i32 1431655765))), (i32 858993459)))), (i32 (i32 4)))), (add (and (i32 (srl (i32 (sub GPR:$rs1, (and (i32 (srl (i32 GPR:$rs1), (i32 (i32 1)))), (i32 1431655765)))), (i32 (i32 2)))), (i32 858993459)), (and (sub GPR:$rs1, (and (i32 (srl (i32 GPR:$rs1), (i32 (i32 1)))), (i32 1431655765))), (i32 858993459)))), (i32 252645135)), (i32 16843009))), (i32 (i32 24))))),
	(SEAL5_CV_CNT_ GPR:$rs1)>;

}

