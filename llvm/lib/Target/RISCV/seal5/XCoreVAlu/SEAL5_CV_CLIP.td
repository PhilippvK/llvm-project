let Predicates = [HasVendorXCoreVAlu, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SEAL5_CV_CLIP_ : RVInst_SEAL5_CV_CLIP<(outs GPR:$rd), (ins GPR:$rs1, uimm5:$Iuimm5)>;

def : Pat<
	(i32 (select (i32 (setcc (i32 GPR:$rs1), (i32 (select (i32 (setcc (i32 (i32 uimm5:$Iuimm5)), (i32 (i32 0)), SETEQ)), (i32 -1), (sub (i32 0), (i32 (shl (i32 (i32 1)), (i32 (add (i32 uimm5:$Iuimm5), (i32 -1)))))))), SETGT)), (select (i32 (setcc (i32 GPR:$rs1), (i32 (select (i32 (setcc (i32 (i32 uimm5:$Iuimm5)), (i32 (i32 0)), SETEQ)), (i32 0), (add (i32 (shl (i32 (i32 1)), (i32 (add (i32 uimm5:$Iuimm5), (i32 -1))))), (i32 -1)))), SETLT)), GPR:$rs1, (select (i32 (setcc (i32 (i32 uimm5:$Iuimm5)), (i32 (i32 0)), SETEQ)), (i32 0), (add (i32 (shl (i32 (i32 1)), (i32 (add (i32 uimm5:$Iuimm5), (i32 -1))))), (i32 -1)))), (select (i32 (setcc (i32 (i32 uimm5:$Iuimm5)), (i32 (i32 0)), SETEQ)), (i32 -1), (sub (i32 0), (i32 (shl (i32 (i32 1)), (i32 (add (i32 uimm5:$Iuimm5), (i32 -1))))))))),
	(SEAL5_CV_CLIP_ GPR:$rs1, uimm5:$Iuimm5)>;

}

