let Predicates = [HasVendorXCoreVMem, IsRV32] in {
class RVInst_SEAL5_CV_SW_rr<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rs3;
    bits<5> rs1;
    bits<5> rs2;

    // Attributes
    let hasSideEffects = 0;
    let mayLoad = 0;
    let mayStore = 1;
    let isTerminator = 0;

    // Encoding

    let Inst{31-25} = 0b0010110;

    let Inst{24-20} = rs2;

    let Inst{19-15} = rs1;

    let Inst{14-12} = 0b011;

    let Inst{11-7} = rs3;

    let Inst{6-0} = 0b0101011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "seal5.cv.sw\t$rs2, ${rs3}(${rs1})";

}
def SEAL5_CV_SW_rr : RVInst_SEAL5_CV_SW_rr<(outs ), (ins GPR:$rs2, GPR:$rs3, GPR:$rs1)>;

}
