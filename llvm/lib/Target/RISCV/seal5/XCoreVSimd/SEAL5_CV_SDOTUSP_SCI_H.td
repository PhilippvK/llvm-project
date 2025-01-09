let Predicates = [HasVendorXCoreVSimd, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def SEAL5_CV_SDOTUSP_SCI_H_ : RVInst_SEAL5_CV_SDOTUSP_SCI_H<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, simm6:$Imm6)>;

def : Pat<
	(i32 (add (add GPR:$rd, (i32 (sra (i32 (i32 (shl (i32 (mul GPR:$rs1, (i32 simm6:$Imm6))), (i32 (i32 16))))), (i32 (i32 16))))), (i32 (sra (i32 (i32 (shl (i32 (mul (i32 (srl GPR:$rs1, (i32 16))), (i32 simm6:$Imm6))), (i32 (i32 16))))), (i32 (i32 16)))))),
	(SEAL5_CV_SDOTUSP_SCI_H_ GPR:$rd, GPR:$rs1, simm6:$Imm6)>;

}

