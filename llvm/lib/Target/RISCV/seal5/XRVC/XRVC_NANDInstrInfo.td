let Predicates = [HasStdExtXRVC, IsRV32] in {
class RVInst_XRVC_NAND<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let DecoderNamespace = "XRVC";
    let Size = 2;
    bits<16> SoftFail = 0;
    bits<16> Inst;

    // Operands
    bits<3> rs2;
    bits<3> rd;

    // Attributes
    let hasSideEffects = 1;
    let mayLoad = 0;
    let mayStore = 0;
    let isTerminator = 0;

    // Encoding

    let Inst{15-13} = 0b100;

    let Inst{12} = 0b1;

    let Inst{11-10} = 0b11;

    let Inst{9-7} = rd;

    let Inst{6-5} = 0b11;

    let Inst{4-2} = rs2;

    let Inst{1-0} = 0b01;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "xrvc.nand\t$rd, $rs2";

    // Constraints
    let Constraints = "$rd = $rd_wb";
}
def XRVC_NAND : RVInst_XRVC_NAND<(outs GPRC:$rd_wb), (ins GPRC:$rd, GPRC:$rs2)>;

def : CompressPat<(XRV_NAND GPRC:$rd, GPRC:$rd, GPRC:$rs2), (XRVC_NAND GPRC:$rd, GPRC:$rs2)>;
}
