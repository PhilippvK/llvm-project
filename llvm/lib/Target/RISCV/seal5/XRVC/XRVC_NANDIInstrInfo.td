let Predicates = [HasStdExtXRVC, IsRV32] in {
class RVInst_XRVC_NANDI<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let DecoderNamespace = "XRVC";
    let Size = 2;
    bits<16> SoftFail = 0;
    bits<16> Inst;

    // Operands
    bits<6> imm;
    bits<3> rd;

    // Attributes
    let hasSideEffects = 1;
    let mayLoad = 0;
    let mayStore = 0;
    let isTerminator = 0;

    // Encoding

    let Inst{15-13} = 0b100;

    let Inst{12} = imm{5};

    let Inst{11-10} = 0b10;

    let Inst{9-7} = rd;

    let Inst{6-2} = imm{4-0};

    let Inst{1-0} = 0b00;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "xrvc.nandi\t$rd, $imm";

    // Constraints
    let Constraints = "$rd = $rd_wb";
}
def XRVC_NANDI : RVInst_XRVC_NANDI<(outs GPRC:$rd_wb), (ins GPRC:$rd, seal5_uimm6:$imm)>;

def : CompressPat<(XRV_NANDI GPRC:$rd, GPRC:$rd, seal5_uimm6:$imm), (XRVC_NANDI GPRC:$rd, seal5_uimm6:$imm)>;
}
