let Predicates = [HasVendorOpenASIPbase, IsRV32] in {

let hasSideEffects = 0, mayLoad = 1, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def OpenASIP_base_DIV_ : RVInst_OpenASIP_base_DIV<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (sdiv GPR:$rs1, GPR:$rs2)),
	(OpenASIP_base_DIV_ GPR:$rs1, GPR:$rs2)>;

}

