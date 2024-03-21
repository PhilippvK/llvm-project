let Predicates = [HasVendorSeal5Testalucvmini1232, IsRV32] in {
// class RVInst_GEN_cv_mini12_32<dag outs, dag ins> : RVInst<outs, ins, "cv.add.h", "$rd, $rs1, $rs2", [], InstFormatOther> {
class RVInst_GEN_cv_mini12_32<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd;
    bits<5> rs1;
    bits<12> imm5;

    // Attributes
    let hasSideEffects = 0;
    let mayLoad = 0;
    let mayStore = 0;
    let isTerminator = 0;

    // Encoding

    let Inst{31-20} = imm5;

    let Inst{19-15} = rs1;

    let Inst{14-12} = 0b010;

    let Inst{11-7} = rd;

    let Inst{6-0} = 0b1111011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "gen.cv.mini12.32\t$rd, $rs1, $imm5";

}
def GEN_cv_mini12_32 : RVInst_GEN_cv_mini12_32<(outs GPR:$rd), (ins GPR:$rs1, uimm12:$imm5)>;

}
