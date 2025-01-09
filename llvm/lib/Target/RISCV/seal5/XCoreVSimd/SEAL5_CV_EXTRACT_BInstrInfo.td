let Predicates = [HasVendorXCoreVSimd, IsRV32] in {
class RVInst_SEAL5_CV_EXTRACT_B<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd;
    bits<5> rs1;
    bits<6> Imm6;

    // Attributes
    let hasSideEffects = 0;
    let mayLoad = 0;
    let mayStore = 0;
    let isTerminator = 0;

    // Encoding

    let Inst{31-27} = 0b10111;

    let Inst{26} = 0b0;

    let Inst{25} = Imm6{0};

    let Inst{24-20} = Imm6{5-1};

    let Inst{19-15} = rs1;

    let Inst{14-12} = 0b001;

    let Inst{11-7} = rd;

    let Inst{6-0} = 0b1111011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "seal5.cv.extract.b\t$rd, $rs1, $Imm6";

}
def SEAL5_CV_EXTRACT_B : RVInst_SEAL5_CV_EXTRACT_B<(outs GPR:$rd), (ins GPR:$rs1, uimm6:$Imm6)>;
class Pat_SEAL5_CV_EXTRACT_B<SDPatternOperator OpNode, Instruction Inst>
: Pat<(OpNode GPR:$rs1, uimm6:$Imm6), (Inst GPR:$rs1, uimm6:$Imm6)>;
def : Pat_SEAL5_CV_EXTRACT_B<int_riscv_xcorevsimd_simd_extract_b, SEAL5_CV_EXTRACT_B>;
}
