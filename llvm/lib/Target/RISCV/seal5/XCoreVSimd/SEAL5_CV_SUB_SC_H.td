let Predicates = [HasVendorXCoreVSimd, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 1, isCodeGenOnly = 1, Constraints = "" in def SEAL5_CV_SUB_SC_H_ : RVInst_SEAL5_CV_SUB_SC_H<(outs ), (ins uimm5:$rd, GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(truncstorei16 (XLenVT (sub (i32 (srl GPR:$rs1, (i32 16))), GPR:$rs2)), (iPTR (ptradd (iPTR (i32 uimm5:$rd)), (i32 (i32 2))))),
	(SEAL5_CV_SUB_SC_H_ uimm5:$rd, GPR:$rs1, GPR:$rs2)>;

}

