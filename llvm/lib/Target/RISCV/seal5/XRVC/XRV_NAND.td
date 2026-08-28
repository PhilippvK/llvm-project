let Predicates = [HasStdExtXRVC, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def XRV_NAND_ : RVInst_XRV_NAND<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (xor (and GPR:$rs2, GPR:$rs1), (i32 -1))),
	(XRV_NAND_ GPR:$rs1, GPR:$rs2)>;

}

