let Predicates = [HasVendorXOpenASIPbase, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def OpenASIP_base_ADD_ : RVInst_OpenASIP_base_ADD<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (add GPR:$rs2, GPR:$rs1)),
	(OpenASIP_base_ADD_ GPR:$rs1, GPR:$rs2)>;

}

