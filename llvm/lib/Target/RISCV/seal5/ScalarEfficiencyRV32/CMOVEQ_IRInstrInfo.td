let Predicates = [HasExtScalarEfficiencyRV32, IsRV32] in {
// class RVInst_CMOVEQ_IR<dag outs, dag ins> : RVInst<outs, ins, "cv.add.h", "$rd, $rs1, $rs2", [], InstFormatOther> {
class RVInst_CMOVEQ_IR<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd;
    bits<5> rs1;
    bits<5> imm5;

    // Attributes
    let hasSideEffects = 0;
    let mayLoad = 0;
    let mayStore = 0;
    let isTerminator = 0;

    // Encoding

    let Inst{31-25} = 0b0010001;

    let Inst{24-20} = imm5;

    let Inst{19-15} = rs1;

    let Inst{14-12} = 0b010;

    let Inst{11-7} = rd;

    let Inst{6-0} = 0b1011011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "cmoveq.ir\t$rd, $imm5, $rs1";

    // Constraints
    let Constraints = "$rd = $rd_wb";
}
def CMOVEQ_IR : RVInst_CMOVEQ_IR<(outs GPR:$rd_wb), (ins GPR:$rd, uimm5:$imm5, GPR:$rs1)>;

}
