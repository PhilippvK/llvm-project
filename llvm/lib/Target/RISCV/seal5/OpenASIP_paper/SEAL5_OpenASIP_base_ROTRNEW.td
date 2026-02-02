let Predicates = [HasVendorXOpenASIPpaper, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def SEAL5_OpenASIP_base_ROTRNEW_ : RVInst_SEAL5_OpenASIP_base_ROTRNEW<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (or (i32 (srl (i32 GPR:$rs1), (i32 (and GPR:$rs2, (i32 31))))), (i32 (shl (i32 GPR:$rs1), (i32 (and (sub (i32 0), GPR:$rs2), (i32 31))))))),
	(SEAL5_OpenASIP_base_ROTRNEW_ GPR:$rs1, GPR:$rs2)>;

}

