let Predicates = [HasVendorXCoreVAlu, IsRV32] in {
class RVInst_SEAL5_CV_ADDURN<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd;
    bits<5> rs1;
    bits<5> rs2;
    bits<5> Luimm5;

    // Attributes
    let hasSideEffects = 0;
    let mayLoad = 0;
    let mayStore = 0;
    let isTerminator = 0;

    // Encoding

    let Inst{31-30} = 0b11;

    let Inst{29-25} = Luimm5;

    let Inst{24-20} = rs2;

    let Inst{19-15} = rs1;

    let Inst{14-12} = 0b010;

    let Inst{11-7} = rd;

    let Inst{6-0} = 0b1011011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "seal5.cv.adduRN\t$rd, $rs1, $rs2, $Luimm5";

}
def SEAL5_CV_ADDURN : RVInst_SEAL5_CV_ADDURN<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm5:$Luimm5)>;
class Pat_SEAL5_CV_ADDURN<SDPatternOperator OpNode, Instruction Inst>
: Pat<(OpNode GPR:$rs1, GPR:$rs2, uimm5:$Luimm5), (Inst GPR:$rs1, GPR:$rs2, uimm5:$Luimm5)>;
def : Pat_SEAL5_CV_ADDURN<int_riscv_xcorevalu_alu_addurn, SEAL5_CV_ADDURN>;
}
