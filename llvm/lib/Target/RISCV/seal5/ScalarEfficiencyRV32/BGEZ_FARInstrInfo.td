let Predicates = [HasExtScalarEfficiencyRV32, IsRV32] in {
// class RVInst_BGEZ_FAR<dag outs, dag ins> : RVInst<outs, ins, "cv.add.h", "$rd, $rs1, $rs2", [], InstFormatOther> {
class RVInst_BGEZ_FAR<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<17> simm17;
    bits<5> rs1;

    // Attributes
    let hasSideEffects = 0;
    let mayLoad = 0;
    let mayStore = 0;
    let isTerminator = 0;

    // Encoding

    let Inst{31-20} = simm17{16-5};

    let Inst{19-15} = rs1;

    let Inst{14-12} = 0b001;

    let Inst{11-7} = simm17{4-0};

    let Inst{6-0} = 0b1011011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "bgez.far\t$rs1, $simm17";

}
def BGEZ_FAR : RVInst_BGEZ_FAR<(outs ), (ins GPR:$rs1, uimm17:$simm17)>;

}
