let Predicates = [HasVendorXCoreVAlu, IsRV32] in {
class RVInst_SEAL5_CV_CLIP<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd;
    bits<5> rs1;
    bits<5> Iuimm5;

    // Attributes
    let hasSideEffects = 0;
    let mayLoad = 0;
    let mayStore = 0;
    let isTerminator = 0;

    // Encoding

    let Inst{31-25} = 0b0111000;

    let Inst{24-20} = Iuimm5;

    let Inst{19-15} = rs1;

    let Inst{14-12} = 0b011;

    let Inst{11-7} = rd;

    let Inst{6-0} = 0b0101011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "seal5.cv.clip\t$rd, $rs1, $Iuimm5";

}
def SEAL5_CV_CLIP : RVInst_SEAL5_CV_CLIP<(outs GPR:$rd), (ins GPR:$rs1, uimm5:$Iuimm5)>;
class Pat_SEAL5_CV_CLIP<SDPatternOperator OpNode, Instruction Inst>
: Pat<(OpNode GPR:$rs1, uimm5:$Iuimm5), (Inst GPR:$rs1, uimm5:$Iuimm5)>;
def : Pat_SEAL5_CV_CLIP<int_riscv_xcorevalu_alu_clip, SEAL5_CV_CLIP>;
}
