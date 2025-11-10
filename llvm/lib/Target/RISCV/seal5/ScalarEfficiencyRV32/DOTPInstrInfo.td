let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {
class RVInst_DOTP<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd;
    bits<5> rs1;
    bits<5> rs2;

    // Attributes
    let hasSideEffects = 0;
    let mayLoad = 1;
    let mayStore = 0;
    let isTerminator = 0;
    let isBranch = 0;

    // Encoding

    let Inst{31-25} = 0b0000000;

    let Inst{24-20} = rs2;

    let Inst{19-15} = rs1;

    let Inst{14-12} = 0b010;

    let Inst{11-7} = rd;

    let Inst{6-0} = 0b0001011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "dotp\t$rd, $rs1, $rs2";

    // Constraints
    let Constraints = "$rd = $rd_wb, $rs1 = $rs1_wb, $rs2 = $rs2_wb";
}
def DOTP : RVInst_DOTP<(outs GPR:$rd_wb, GPR:$rs1_wb, GPR:$rs2_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2)>;

}
