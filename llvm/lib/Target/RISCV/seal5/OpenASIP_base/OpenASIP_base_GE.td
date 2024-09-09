let Predicates = [HasVendorOpenASIPbase, IsRV32] in {

let hasSideEffects = 0, mayLoad = 1, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def OpenASIP_base_GE_ : RVInst_OpenASIP_base_GE<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (i32 (setcc (i32 GPR:$rs2), (i32 GPR:$rs1), SETLE))),
	(OpenASIP_base_GE_ GPR:$rs1, GPR:$rs2)>;

}

