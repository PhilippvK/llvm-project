let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {
class RVInst_CMOVGEU_II<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let DecoderNamespace = "ScalarEfficiencyRV32";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd;
    bits<5> imm5_2;
    bits<5> uimm5;

    // Attributes
    let hasSideEffects = 1;
    let mayLoad = 0;
    let mayStore = 0;
    let isTerminator = 0;

    // Encoding

    let Inst{31-25} = 0b0011100;

    let Inst{24-20} = uimm5;

    let Inst{19-15} = imm5_2;

    let Inst{14-12} = 0b010;

    let Inst{11-7} = rd;

    let Inst{6-0} = 0b1011011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "cmovgeu.ii\t$rd, $imm5_2, $uimm5";

    // Constraints
    let Constraints = "$rd = $rd_wb";
}
def CMOVGEU_II : RVInst_CMOVGEU_II<(outs GPR:$rd_wb), (ins GPR:$rd, seal5_uimm5:$imm5_2, seal5_uimm5:$uimm5)>;

}
