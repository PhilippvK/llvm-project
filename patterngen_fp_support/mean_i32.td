let Predicates = [HasVendorXCValu] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "" in def MEAN_ : RVInst_MEAN<(outs GPR:$rd), (ins GPR:$rs2, GPR:$rs1)>;

def : Pat<
	(i32 (i32 (srl (i32 (add GPR:$rs2, GPR:$rs1)), (i32 (i32 1))))),
	(MEAN_ GPR:$rs2, GPR:$rs1)>;

}
