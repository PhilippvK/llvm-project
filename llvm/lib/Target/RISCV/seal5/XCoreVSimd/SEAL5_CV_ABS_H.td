let Predicates = [HasVendorXCoreVSimd, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 1, isCodeGenOnly = 1, Constraints = "" in def SEAL5_CV_ABS_H_ : RVInst_SEAL5_CV_ABS_H<(outs ), (ins uimm5:$rd, GPR:$rs1)>;

def : Pat<
	(truncstorei16 (XLenVT (xor (add (i32 (srl GPR:$rs1, (i32 16))), (i32 (sra (i32 (i32 (sra (i32 (i32 (shl (i32 (i32 (srl GPR:$rs1, (i32 16)))), (i32 (i32 16))))), (i32 (i32 16))))), (i32 (i32 15))))), (i32 (sra (i32 (i32 (sra (i32 (i32 (shl (i32 (i32 (srl GPR:$rs1, (i32 16)))), (i32 (i32 16))))), (i32 (i32 16))))), (i32 (i32 15)))))), (iPTR (ptradd (iPTR (i32 uimm5:$rd)), (i32 (i32 2))))),
	(SEAL5_CV_ABS_H_ uimm5:$rd, GPR:$rs1)>;

}

