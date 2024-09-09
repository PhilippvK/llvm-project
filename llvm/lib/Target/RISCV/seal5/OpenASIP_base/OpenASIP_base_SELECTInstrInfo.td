let Predicates = [HasVendorOpenASIPbase, IsRV32] in {
class RVInst_OpenASIP_base_SELECT<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd;
    bits<5> rs1;
    bits<5> rs2;
    bits<5> rs3;

    // Attributes
    let hasSideEffects = 0;
    let mayLoad = 0;
    let mayStore = 0;
    let isTerminator = 0;

    // Encoding

    let Inst{31-27} = rs3;

    let Inst{26-25} = 0b00;

    let Inst{24-20} = rs2;

    let Inst{19-15} = rs1;

    let Inst{14-12} = 0b001;

    let Inst{11-7} = rd;

    let Inst{6-0} = 0b0110011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "openasip_base_select\t$rd, $rs1, $rs2, $rs3";

}
def OpenASIP_base_SELECT : RVInst_OpenASIP_base_SELECT<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, GPR:$rs3)>;

}
