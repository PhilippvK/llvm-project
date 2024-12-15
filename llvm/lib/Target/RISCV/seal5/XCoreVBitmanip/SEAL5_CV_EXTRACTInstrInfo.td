let Predicates = [HasVendorXCoreVBitmanip, IsRV32] in {
class RVInst_SEAL5_CV_EXTRACT<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd;
    bits<5> rs1;
    bits<5> Iuimm5;
    bits<5> Luimm5;

    // Attributes
    let hasSideEffects = 0;
    let mayLoad = 0;
    let mayStore = 0;
    let isTerminator = 0;

    // Encoding

    let Inst{31-30} = 0b00;

    let Inst{29-25} = Luimm5;

    let Inst{24-20} = Iuimm5;

    let Inst{19-15} = rs1;

    let Inst{14-12} = 0b000;

    let Inst{11-7} = rd;

    let Inst{6-0} = 0b1011011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "seal5.cv.extract\t$rd, $rs1, $Luimm5, $Iuimm5";

}
def SEAL5_CV_EXTRACT : RVInst_SEAL5_CV_EXTRACT<(outs GPR:$rd), (ins GPR:$rs1, uimm5:$Luimm5, uimm5:$Iuimm5)>;

}
