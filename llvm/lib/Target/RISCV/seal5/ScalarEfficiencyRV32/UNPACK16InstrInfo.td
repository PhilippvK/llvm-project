let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {
class RVInst_UNPACK16<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd1;
    bits<5> rd2;
    bits<5> rs1;

    // Attributes
    let hasSideEffects = 0;
    let mayLoad = 0;
    let mayStore = 0;
    let isTerminator = 0;
    let isBranch = 0;

    // Encoding

    let Inst{31-25} = 0b0000001;

    let Inst{24-20} = rs1;

    let Inst{19-15} = rd2;

    let Inst{14-12} = 0b010;

    let Inst{11-7} = rd1;

    let Inst{6-0} = 0b0101011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "unpack16\t$rd1, $rd2, $rs1";

}
def UNPACK16 : RVInst_UNPACK16<(outs GPR:$rd1, GPR:$rd2), (ins GPR:$rs1)>;

}
