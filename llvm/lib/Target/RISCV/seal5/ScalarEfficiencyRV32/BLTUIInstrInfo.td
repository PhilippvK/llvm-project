let Predicates = [HasExtScalarEfficiencyRV32, IsRV32] in {
// class RVInst_BLTUI<dag outs, dag ins> : RVInst<outs, ins, "cv.add.h", "$rd, $rs1, $rs2", [], InstFormatOther> {
class RVInst_BLTUI<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<12> simm12;
    bits<5> rs1;
    bits<5> uimm5;

    // Attributes
    let hasSideEffects = 0;
    let mayLoad = 0;
    let mayStore = 0;
    let isTerminator = 0;

    // Encoding

    let Inst{31-25} = simm12{11-5};

    let Inst{24-20} = uimm5;

    let Inst{19-15} = rs1;

    let Inst{14-12} = 0b011;

    let Inst{11-7} = simm12{4-0};

    let Inst{6-0} = 0b1111011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "bltui\t$rs1, $simm12, $uimm5";

}
def BLTUI : RVInst_BLTUI<(outs ), (ins GPR:$rs1, uimm12:$simm12, uimm5:$uimm5)>;

}
