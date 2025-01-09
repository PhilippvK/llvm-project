let Predicates = [HasVendorXCoreVSimd, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 1, isCodeGenOnly = 1, Constraints = "" in def SEAL5_CV_MAX_SC_B_ : RVInst_SEAL5_CV_MAX_SC_B<(outs ), (ins uimm5:$rd, GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(truncstorei8 (XLenVT (select (i32 (setcc (i32 (i32 (sra (i32 (i32 (shl (i32 (i32 (srl GPR:$rs1, (i32 24)))), (i32 (i32 24))))), (i32 (i32 24))))), (i32 (i32 (sra (i32 (i32 (shl (i32 GPR:$rs2), (i32 (i32 24))))), (i32 (i32 24))))), SETGT)), (i32 (srl GPR:$rs1, (i32 24))), GPR:$rs2)), (iPTR (ptradd (iPTR (i32 uimm5:$rd)), (i32 (i32 3))))),
	(SEAL5_CV_MAX_SC_B_ uimm5:$rd, GPR:$rs1, GPR:$rs2)>;

}

