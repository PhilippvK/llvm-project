let Predicates = [HasVendorSeal5Testalucvmaxi516, IsRV32] in {
// class RVInst_GEN_cv_maxi5_16<dag outs, dag ins> : RVInst<outs, ins, "cv.add.h", "$rd, $rs1, $rs2", [], InstFormatOther> {
class RVInst_GEN_cv_maxi5_16<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd;
    bits<5> rs1;
    bits<5> imm5;

    // Attributes
    let hasSideEffects = 0;
    let mayLoad = 0;
    let mayStore = 0;
    let isTerminator = 0;

    // Encoding

    let Inst{31-25} = 0b0000011;

    let Inst{24-20} = imm5;

    let Inst{19-15} = rs1;

    let Inst{14-12} = 0b000;

    let Inst{11-7} = rd;

    let Inst{6-0} = 0b1111011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "gen.cv.maxi5.16\t$rd, $rs1, $imm5";

}
def GEN_cv_maxi5_16 : RVInst_GEN_cv_maxi5_16<(outs GPR:$rd), (ins GPR:$rs1, uimm5:$imm5)>;

}
