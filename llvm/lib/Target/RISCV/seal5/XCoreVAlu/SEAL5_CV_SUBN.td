let Predicates = [HasVendorXCoreVAlu, IsRV32] in {

let hasSideEffects = 0, mayLoad = 1, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SEAL5_CV_SUBN_ : RVInst_SEAL5_CV_SUBN<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$Luimm5)>;

def : Pat<
	(i32 (i32 (sra (i32 (sub GPR:$rs1, GPR:$rs2)), (i32 (i32 uimm5:$Luimm5))))),
	(SEAL5_CV_SUBN_ GPR:$rs1, GPR:$rs2, uimm5:$Luimm5)>;

}

