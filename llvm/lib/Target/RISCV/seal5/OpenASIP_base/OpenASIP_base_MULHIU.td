let Predicates = [HasVendorOpenASIPbase, IsRV32] in {

let hasSideEffects = 0, mayLoad = 1, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def OpenASIP_base_MULHIU_ : RVInst_OpenASIP_base_MULHIU<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (add (add (mul GPR:$rs1, (i32 0)), (mul GPR:$rs2, (i32 0))), (mulhu GPR:$rs2, GPR:$rs1))),
	(OpenASIP_base_MULHIU_ GPR:$rs1, GPR:$rs2)>;

}

