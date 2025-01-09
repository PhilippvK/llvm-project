let Predicates = [HasVendorXCoreVSimd, IsRV32] in {
class RVInst_SEAL5_CV_CPLXMUL_I<dag outs, dag ins> : Instruction, Sched<[]> {
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

    let Inst{31-27} = 0b01010;

    let Inst{26} = 0b1;

    let Inst{25} = 0b1;

    let Inst{24-20} = rs2;

    let Inst{19-15} = rs1;

    let Inst{14-12} = 0b000;

    let Inst{11-7} = rd;

    let Inst{6-0} = 0b1111011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "seal5.cv.cplxmul.i\t$rd, $rs1, $rs2";

    // Constraints
    let Constraints = "$rd = $rd_wb";
}
def SEAL5_CV_CPLXMUL_I : RVInst_SEAL5_CV_CPLXMUL_I<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2)>;
class Pat_SEAL5_CV_CPLXMUL_I<SDPatternOperator OpNode, Instruction Inst>
: Pat<(OpNode GPR:$rd, GPR:$rs1, GPR:$rs2), (Inst GPR:$rd, GPR:$rs1, GPR:$rs2)>;
def : Pat_SEAL5_CV_CPLXMUL_I<int_riscv_xcorevsimd_simd_cplxmul_i, SEAL5_CV_CPLXMUL_I>;
}
