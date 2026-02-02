let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 1, Constraints = "$rd = $rd_wb" in def LI16_ : RVInst_LI16<(outs GPR:$rd_wb), (ins GPR:$rd, uimm16:$imm16, uimm1:$n)>;

def : Pat<
	(i32 (or (select (i32 (setcc (i32 (i32 uimm1:$n)), (i32 (i32 0)), SETEQ)), (i32 0), GPR:$rd), (i32 (shl (i32 (i32 uimm16:$imm16)), (i32 (i32 (shl (i32 (i32 uimm1:$n)), (i32 (i32 4))))))))),
	(LI16_ GPR:$rd, uimm16:$imm16, uimm1:$n)>;

}

