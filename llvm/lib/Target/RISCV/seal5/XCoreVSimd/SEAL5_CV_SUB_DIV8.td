let Predicates = [HasVendorXCoreVSimd, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 1, isCodeGenOnly = 1, Constraints = "" in def SEAL5_CV_SUB_DIV8_ : RVInst_SEAL5_CV_SUB_DIV8<(outs ), (ins uimm5:$rd, GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(truncstorei16 (XLenVT (i32 (sra (i32 (i32 (sra (i32 (i32 (shl (i32 (sub (i32 (srl GPR:$rs1, (i32 16))), (i32 (srl GPR:$rs2, (i32 16))))), (i32 (i32 16))))), (i32 (i32 16))))), (i32 (i32 3))))), (iPTR (ptradd (iPTR (i32 uimm5:$rd)), (i32 (i32 2))))),
	(SEAL5_CV_SUB_DIV8_ uimm5:$rd, GPR:$rs1, GPR:$rs2)>;

}

