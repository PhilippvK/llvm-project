let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {
class RVInst_INSBI<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let DecoderNamespace = "ScalarEfficiencyRV32";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd;
    bits<5> imm5;
    bits<5> width5;
    bits<5> shamt5;

    // Attributes
    let hasSideEffects = 1;
    let mayLoad = 0;
    let mayStore = 0;
    let isTerminator = 0;

    // Encoding

    let Inst{31-30} = 0b11;

    let Inst{29-25} = shamt5;

    let Inst{24-20} = width5;

    let Inst{19-15} = imm5;

    let Inst{14-12} = 0b100;

    let Inst{11-7} = rd;

    let Inst{6-0} = 0b1011011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "extu\t$rd, $imm5, $width5, $shamt5";

}
def INSBI : RVInst_INSBI<(outs GPR:$rd), (ins uimm5:$imm5, uimm5:$width5, uimm5:$shamt5)>;

}
