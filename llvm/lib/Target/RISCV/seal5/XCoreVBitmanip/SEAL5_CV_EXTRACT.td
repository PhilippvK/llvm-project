let Predicates = [HasVendorXCoreVBitmanip, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SEAL5_CV_EXTRACT_ : RVInst_SEAL5_CV_EXTRACT<(outs GPR:$rd), (ins GPR:$rs1, uimm5:$Iuimm5, uimm5:$Luimm5)>;

def : Pat<
	(i32 (and (i32 (srl (i32 GPR:$rs1), (i32 (i32 uimm5:$Iuimm5)))), (add (i32 (shl (i32 (i32 2)), (i32 (i32 uimm5:$Luimm5)))), (i32 -1)))),
	(SEAL5_CV_EXTRACT_ GPR:$rs1, uimm5:$Iuimm5, uimm5:$Luimm5)>;

}

