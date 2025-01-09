let Predicates = [HasVendorXCoreVSimd, IsRV32] in {
class RVInst_SEAL5_CV_AVG_H<dag outs, dag ins> : Instruction, Sched<[]> {
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

    let Inst{31-27} = 0b00010;

    let Inst{26} = 0b0;

    let Inst{25} = 0b0;

    let Inst{24-20} = rs2;

    let Inst{19-15} = rs1;

    let Inst{14-12} = 0b000;

    let Inst{11-7} = rd;

    let Inst{6-0} = 0b1111011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "seal5.cv.avg.h\t$rd, $rs1, $rs2";

}
def SEAL5_CV_AVG_H : RVInst_SEAL5_CV_AVG_H<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;
class Pat_SEAL5_CV_AVG_H<SDPatternOperator OpNode, Instruction Inst>
: Pat<(OpNode GPR:$rs1, GPR:$rs2), (Inst GPR:$rs1, GPR:$rs2)>;
def : Pat_SEAL5_CV_AVG_H<int_riscv_xcorevsimd_simd_avg_h, SEAL5_CV_AVG_H>;
}
