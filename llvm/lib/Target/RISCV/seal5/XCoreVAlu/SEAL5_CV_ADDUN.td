let Predicates = [HasVendorXCoreVAlu, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SEAL5_CV_ADDUN_ : RVInst_SEAL5_CV_ADDUN<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$Luimm5)>;

def : Pat<
	(i32 (i32 (srl (i32 (add GPR:$rs2, GPR:$rs1)), (i32 (i32 uimm5:$Luimm5))))),
	(SEAL5_CV_ADDUN_ GPR:$rs1, GPR:$rs2, uimm5:$Luimm5)>;

}

