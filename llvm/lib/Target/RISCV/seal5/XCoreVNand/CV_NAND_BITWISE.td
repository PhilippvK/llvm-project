let Predicates = [HasStdExtXCoreVNand, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def CV_NAND_BITWISE_ : RVInst_CV_NAND_BITWISE<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

def : Pat<
	(i32 (xor (and GPR:$rs2, GPR:$rs1), (i32 -1))),
	(CV_NAND_BITWISE_ GPR:$rs1, GPR:$rs2)>;

}

