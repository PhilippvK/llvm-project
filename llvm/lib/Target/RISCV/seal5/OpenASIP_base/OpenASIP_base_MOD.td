let Predicates = [HasVendorXOpenASIPbase, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def OpenASIP_base_MOD_ : RVInst_OpenASIP_base_MOD<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (srem GPR:$rs1, GPR:$rs2)),
	(OpenASIP_base_MOD_ GPR:$rs1, GPR:$rs2)>;

}

