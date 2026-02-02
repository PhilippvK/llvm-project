let Predicates = [HasVendorXOpenASIPbase, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def OpenASIP_base_SELECT_ : RVInst_OpenASIP_base_SELECT<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, GPR:$rs3)>;

def : Pat<
	(i32 (select (i32 (setcc (i32 (and GPR:$rs3, (i32 1))), (i32 (i32 0)), SETEQ)), GPR:$rs2, GPR:$rs1)),
	(OpenASIP_base_SELECT_ GPR:$rs1, GPR:$rs2, GPR:$rs3)>;

}

