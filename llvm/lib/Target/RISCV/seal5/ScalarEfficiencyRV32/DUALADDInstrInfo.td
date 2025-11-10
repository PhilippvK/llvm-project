let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {
class RVInst_DUALADD<dag outs, dag ins> : Instruction, Sched<[]> {
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

    let Inst{14-12} = 0b110;

    let Inst{11-7} = rd1;

    let Inst{6-0} = 0b0001011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "dualadd\t$rd1, $rd2, $rs1";

    // Constraints
    let Constraints = "$rd1 = $rd1_wb, $rd2 = $rd2_wb";
}
def DUALADD : RVInst_DUALADD<(outs GPR:$rd1_wb, GPR:$rd2_wb), (ins GPR:$rd1, GPR:$rd2, GPR:$rs1)>;

}
