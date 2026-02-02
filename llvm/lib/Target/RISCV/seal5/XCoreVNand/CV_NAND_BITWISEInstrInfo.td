let Predicates = [HasStdExtXCoreVNand, IsRV32] in {
class RVInst_CV_NAND_BITWISE<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let DecoderNamespace = "XCoreVNand";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd;
    bits<5> rs1;
    bits<5> rs2;

    // Attributes
    let hasSideEffects = 1;
    let mayLoad = 0;
    let mayStore = 0;
    let isTerminator = 0;

    // Encoding

    let Inst{31-25} = 0b1001001;

    let Inst{24-20} = rs2;

    let Inst{19-15} = rs1;

    let Inst{14-12} = 0b110;

    let Inst{11-7} = rd;

    let Inst{6-0} = 0b0101011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "cv.nand.bitwise\t$rd, $rs1, $rs2";

}
def CV_NAND_BITWISE : RVInst_CV_NAND_BITWISE<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2)>;
class Pat_CV_NAND_BITWISE<SDPatternOperator OpNode, Instruction Inst>
: Pat<(OpNode GPR:$rs1, GPR:$rs2), (Inst GPR:$rs1, GPR:$rs2)>;
def : Pat_CV_NAND_BITWISE<int_riscv_xcorevnand_xcv_nand_bitwise, CV_NAND_BITWISE>;
}
