let Predicates = [HasVendorOpenASIPbase, IsRV32] in {

let hasSideEffects = 0, mayLoad = 1, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def OpenASIP_base_ROTR_ : RVInst_OpenASIP_base_ROTR<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (or (i32 (srl (i32 GPR:$rs1), (i32 (and GPR:$rs2, (i32 31))))), (i32 (shl (i32 GPR:$rs1), (i32 (and (sub (i32 0), GPR:$rs2), (i32 31))))))),
	(OpenASIP_base_ROTR_ GPR:$rs1, GPR:$rs2)>;

}

