let Predicates = [HasVendorXCoreVSimd, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 1, isCodeGenOnly = 1, Constraints = "" in def SEAL5_CV_CMPGEU_SCI_B_ : RVInst_SEAL5_CV_CMPGEU_SCI_B<(outs ), (ins uimm5:$rd, GPR:$rs1, uimm6:$Imm6)>;

def : Pat<
	(truncstorei8 (XLenVT (i32 (sra (i32 (i32 (shl (i32 (i32 (setcc (i32 (i32 (srl GPR:$rs1, (i32 24)))), (i32 (i32 uimm6:$Imm6)), SETUGE))), (i32 (i32 31))))), (i32 (i32 31))))), (iPTR (ptradd (iPTR (i32 uimm5:$rd)), (i32 (i32 3))))),
	(SEAL5_CV_CMPGEU_SCI_B_ uimm5:$rd, GPR:$rs1, uimm6:$Imm6)>;

}

