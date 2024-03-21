let Predicates = [HasVendorSeal5TestmaccvmachhRNs, IsRV32] in {
// class RVInst_GEN_cv_machhRNs<dag outs, dag ins> : RVInst<outs, ins, "cv.add.h", "$rd, $rs1, $rs2", [], InstFormatOther> {
class RVInst_GEN_cv_machhRNs<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd;
    bits<5> rs1;
    bits<5> rs2;
    bits<5> Is3;

    // Attributes
    let hasSideEffects = 0;
    let mayLoad = 0;
    let mayStore = 0;
    let isTerminator = 0;

    // Encoding

    let Inst{31-30} = 0b11;

    let Inst{29-25} = Is3;

    let Inst{24-20} = rs2;

    let Inst{19-15} = rs1;

    let Inst{14-12} = 0b010;

    let Inst{11-7} = rd;

    let Inst{6-0} = 0b1011011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "gen.cv.machhRNs\t$rd, $rs1, $rs2, $Is3";

}
def GEN_cv_machhRNs : RVInst_GEN_cv_machhRNs<(outs GPR:$rd_wb), (ins GPR:$rd, GPR:$rs1, GPR:$rs2, uimm5:$Is3)>;

}
