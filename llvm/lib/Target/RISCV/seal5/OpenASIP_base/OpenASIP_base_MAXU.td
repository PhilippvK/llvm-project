let Predicates = [HasVendorOpenASIPbase, IsRV32] in {

let hasSideEffects = 0, mayLoad = 1, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def OpenASIP_base_MAXU_ : RVInst_OpenASIP_base_MAXU<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (select (i32 (setcc (i32 GPR:$rs1), (i32 GPR:$rs2), SETUGT)), GPR:$rs1, GPR:$rs2)),
	(OpenASIP_base_MAXU_ GPR:$rs1, GPR:$rs2)>;

}

