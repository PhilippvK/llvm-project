let Predicates = [HasVendorXOpenASIPpaper, IsRV32] in {
class RVInst_SEAL5_ROTL32<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let DecoderNamespace = "OpenASIP_paper";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd;
    bits<5> rs1;
    bits<5> rs2;

    // Attributes
    let hasSideEffects = 1;
    let mayLoad = 0;
    let mayStore = 0;
    let isTerminator = 0;

    // Encoding

    let Inst{31-25} = 0b0010000;

    let Inst{24-20} = rs2;

    let Inst{19-15} = rs1;

    let Inst{14-12} = 0b000;

    let Inst{11-7} = rd;

    let Inst{6-0} = 0b0101011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "seal5.oa.rotl32\t$rd, $rs1, $rs2";

}
def SEAL5_ROTL32 : RVInst_SEAL5_ROTL32<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;

}
