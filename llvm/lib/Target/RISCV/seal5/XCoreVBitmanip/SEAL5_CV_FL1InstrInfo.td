let Predicates = [HasVendorXCoreVBitmanip, IsRV32] in {
class RVInst_SEAL5_CV_FL1<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd;
    bits<5> rs1;

    // Attributes
    let hasSideEffects = 0;
    let mayLoad = 0;
    let mayStore = 0;
    let isTerminator = 0;

    // Encoding

    let Inst{31-25} = 0b0100010;

    let Inst{24-20} = 0b00000;

    let Inst{19-15} = rs1;

    let Inst{14-12} = 0b011;

    let Inst{11-7} = rd;

    let Inst{6-0} = 0b0101011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "seal5.cv.fl1\t$rd, $rs1";

}
def SEAL5_CV_FL1 : RVInst_SEAL5_CV_FL1<(outs GPR:$rd), (ins GPR:$rs1)>;
class Pat_SEAL5_CV_FL1<SDPatternOperator OpNode, Instruction Inst>
: Pat<(OpNode GPR:$rs1), (Inst GPR:$rs1)>;
def : Pat_SEAL5_CV_FL1<int_riscv_xcorevbitmanip_bitmanip_fl1, SEAL5_CV_FL1>;
}
