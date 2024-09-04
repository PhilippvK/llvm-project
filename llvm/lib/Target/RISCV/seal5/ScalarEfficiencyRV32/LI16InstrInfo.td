let Predicates = [HasExtScalarEfficiencyRV32, IsRV32] in {
class RVInst_LI16<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd;
    bits<16> imm16;
    bits<1> n;

    // Attributes
    let hasSideEffects = 0;
    let mayLoad = 0;
    let mayStore = 0;
    let isTerminator = 0;

    // Encoding

    let Inst{31} = n;

    let Inst{30-15} = imm16;

    let Inst{14-12} = 0b011;

    let Inst{11-7} = rd;

    let Inst{6-0} = 0b1011011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "li16\t$rd, $imm16, $n";

    // Constraints
    let Constraints = "$rd = $rd_wb";
}
def LI16 : RVInst_LI16<(outs GPR:$rd_wb), (ins GPR:$rd, uimm16:$imm16, uimm1:$n)>;

}
