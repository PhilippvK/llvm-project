let Predicates = [HasVendorOpenASIPbase, IsRV32] in {

let hasSideEffects = 0, mayLoad = 1, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def OpenASIP_base_IOR_ : RVInst_OpenASIP_base_IOR<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (or GPR:$rs2, GPR:$rs1)),
	(OpenASIP_base_IOR_ GPR:$rs1, GPR:$rs2)>;

}

