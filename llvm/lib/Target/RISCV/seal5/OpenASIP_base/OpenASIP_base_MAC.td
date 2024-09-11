let Predicates = [HasVendorOpenASIPbase, IsRV32] in {

let hasSideEffects = 0, mayLoad = 1, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def OpenASIP_base_MAC_ : RVInst_OpenASIP_base_MAC<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, GPR:$rs3)>;

def : Pat<
	(i32 (add (mul GPR:$rs3, GPR:$rs2), GPR:$rs1)),
	(OpenASIP_base_MAC_ GPR:$rs1, GPR:$rs2, GPR:$rs3)>;

}

