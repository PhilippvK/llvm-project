let Predicates = [HasVendorXCoreVSimd, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 1, isCodeGenOnly = 1, Constraints = "" in def SEAL5_CV_AVGU_SCI_H_ : RVInst_SEAL5_CV_AVGU_SCI_H<(outs ), (ins uimm5:$rd, GPR:$rs1, uimm6:$Imm6)>;

def : Pat<
	(truncstorei16 (XLenVT (i32 (srl (i32 (and (add (i32 (srl GPR:$rs1, (i32 16))), (i32 uimm6:$Imm6)), (i32 65535))), (i32 (i32 1))))), (iPTR (ptradd (iPTR (i32 uimm5:$rd)), (i32 (i32 2))))),
	(SEAL5_CV_AVGU_SCI_H_ uimm5:$rd, GPR:$rs1, uimm6:$Imm6)>;

}

