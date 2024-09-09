let Predicates = [HasVendorOpenASIPbase, IsRV32] in {

let hasSideEffects = 0, mayLoad = 1, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def OpenASIP_base_ROTL_ : RVInst_OpenASIP_base_ROTL<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (or (i32 (sra (i32 GPR:$rs1), (i32 (sub (i32 32), GPR:$rs2)))), (i32 (shl (i32 GPR:$rs1), (i32 GPR:$rs2))))),
	(OpenASIP_base_ROTL_ GPR:$rs1, GPR:$rs2)>;

}

