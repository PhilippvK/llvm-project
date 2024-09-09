let Predicates = [HasVendorOpenASIPbase, IsRV32] in {

let hasSideEffects = 0, mayLoad = 1, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def OpenASIP_base_SHR_ : RVInst_OpenASIP_base_SHR<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (i32 (sra (i32 GPR:$rs1), (i32 GPR:$rs2)))),
	(OpenASIP_base_SHR_ GPR:$rs1, GPR:$rs2)>;

}

