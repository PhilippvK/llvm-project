let Predicates = [HasVendorXCoreVAlu, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SEAL5_CV_SUBRN_ : RVInst_SEAL5_CV_SUBRN<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$Luimm5)>;

def : Pat<
	(i32 (i32 (sra (i32 (sub (add GPR:$rs1, (i32 (shl (i32 (i32 1)), (i32 (add (i32 uimm5:$Luimm5), (i32 -1)))))), GPR:$rs2)), (i32 (i32 uimm5:$Luimm5))))),
	(SEAL5_CV_SUBRN_ GPR:$rs1, GPR:$rs2, uimm5:$Luimm5)>;

}

