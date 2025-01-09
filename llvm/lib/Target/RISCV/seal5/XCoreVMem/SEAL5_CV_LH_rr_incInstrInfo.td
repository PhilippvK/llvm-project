let Predicates = [HasVendorXCoreVMem, IsRV32] in {
class RVInst_SEAL5_CV_LH_rr_inc<dag outs, dag ins> : Instruction, Sched<[]> {
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
    let mayLoad = 1;
    let mayStore = 0;
    let isTerminator = 0;

    // Encoding

    let Inst{31-25} = 0b0000001;

    let Inst{24-20} = rs2;

    let Inst{19-15} = rs1;

    let Inst{14-12} = 0b011;

    let Inst{11-7} = rd;

    let Inst{6-0} = 0b0101011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "seal5.cv.lh\t$rd, ${rs2}(${rs1})";

    // Constraints
    let Constraints = "$rs1 = $rs1_wb";
}
def SEAL5_CV_LH_rr_inc : RVInst_SEAL5_CV_LH_rr_inc<(outs GPR:$rd, GPR:$rs1_wb), (ins GPR:$rs2, GPR:$rs1)>;

}
