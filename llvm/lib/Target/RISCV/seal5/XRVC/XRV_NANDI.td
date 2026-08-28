let Predicates = [HasStdExtXRVC, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def XRV_NANDI_ : RVInst_XRV_NANDI<(outs GPR:$rd), (ins GPR:$rs1, seal5_uimm12:$imm)>;

def : Pat<
	(i32 (xor (and GPR:$rs1, (i32 seal5_uimm12:$imm)), (i32 -1))),
	(XRV_NANDI_ GPR:$rs1, seal5_uimm12:$imm)>;

}

