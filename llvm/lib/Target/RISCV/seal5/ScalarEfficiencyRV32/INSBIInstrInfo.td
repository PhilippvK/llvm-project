let Predicates = [HasExtScalarEfficiencyRV32, IsRV32] in {
// class RVInst_INSBI<dag outs, dag ins> : RVInst<outs, ins, "cv.add.h", "$rd, $rs1, $rs2", [], InstFormatOther> {
class RVInst_INSBI<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd;
    bits<5> imm5;
    bits<5> width5;
    bits<5> shamt5;

    // Attributes
    let hasSideEffects = 0;
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

    // Constraints
    let Constraints = "$width5 = $width5_wb";
}
def INSBI : RVInst_INSBI<(outs GPR:$rd, uimm5:$width5_wb, uimm5:$shamt5), (ins uimm5:$imm5, uimm5:$width5)>;

}
