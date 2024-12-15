let Predicates = [HasVendorXCoreVSimd, IsRV32] in {

let hasSideEffects = 0, mayLoad = 1, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SEAL5_CV_DOTSP_SCI_H_ : RVInst_SEAL5_CV_DOTSP_SCI_H<(outs GPR:$rd), (ins GPR:$rs1, simm6:$Imm6)>;

def : Pat<
	(i32 (i32 (sra (i32 (i32 (shl (i32 (mul (add (i32 (srl GPR:$rs1, (i32 16))), GPR:$rs1), (i32 simm6:$Imm6))), (i32 (i32 16))))), (i32 (i32 16))))),
	(SEAL5_CV_DOTSP_SCI_H_ GPR:$rs1, simm6:$Imm6)>;

}

