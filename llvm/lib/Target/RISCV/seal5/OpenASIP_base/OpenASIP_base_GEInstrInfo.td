let Predicates = [HasVendorOpenASIPbase, IsRV32] in {
class RVInst_OpenASIP_base_GE<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd;
    bits<5> rs1;
    bits<5> rs2;

    // Attributes
    let hasSideEffects = 0;
    let mayLoad = 0;
    let mayStore = 0;
    let isTerminator = 0;

    // Encoding

    let Inst{31-25} = 0b0001010;

    let Inst{24-20} = rs2;

    let Inst{19-15} = rs1;

    let Inst{14-12} = 0b000;

    let Inst{11-7} = rd;

    let Inst{6-0} = 0b0001011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "openasip_base_ge\t$rd, $rs1, $rs2";

}
def OpenASIP_base_GE : RVInst_OpenASIP_base_GE<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

}
