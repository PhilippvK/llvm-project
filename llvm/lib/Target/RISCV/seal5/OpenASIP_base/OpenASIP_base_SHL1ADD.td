let Predicates = [HasVendorOpenASIPbase, IsRV32] in {

let hasSideEffects = 0, mayLoad = 1, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def OpenASIP_base_SHL1ADD_ : RVInst_OpenASIP_base_SHL1ADD<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (add (i32 (shl (i32 GPR:$rs1), (i32 (i32 1)))), GPR:$rs2)),
	(OpenASIP_base_SHL1ADD_ GPR:$rs1, GPR:$rs2)>;

}

