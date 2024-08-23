let Predicates = [HasExtScalarEfficiencyRV32, IsRV32] in {
// class RVInst_CMOVGE_II<dag outs, dag ins> : RVInst<outs, ins, "cv.add.h", "$rd, $rs1, $rs2", [], InstFormatOther> {
class RVInst_CMOVGE_II<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd;
    bits<5> simm5;
    bits<5> imm5_2;

    // Attributes
    let hasSideEffects = 0;
    let mayLoad = 0;
    let mayStore = 0;
    let isTerminator = 0;

    // Encoding

    let Inst{31-25} = 0b0011011;

    let Inst{24-20} = imm5_2;

    let Inst{19-15} = simm5;

    let Inst{14-12} = 0b010;

    let Inst{11-7} = rd;

    let Inst{6-0} = 0b1011011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "cmovge.ii\t$rd, $imm5_2, $simm5";

    // Constraints
    let Constraints = "$rd = $rd_wb";
}
def CMOVGE_II : RVInst_CMOVGE_II<(outs GPR:$rd_wb), (ins GPR:$rd, uimm5:$imm5_2, uimm5:$simm5)>;

}
