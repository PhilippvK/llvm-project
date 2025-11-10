let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {
class RVInst_MAC_LD_X2<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd;
    bits<5> rs1;
    bits<5> rs2;
    bits<5> rd2;
    bits<2> imm2;

    // Attributes
    let hasSideEffects = 0;
    let mayLoad = 1;
    let mayStore = 0;
    let isTerminator = 0;
    let isBranch = 0;

    // Encoding

    let Inst{31-30} = imm2;

    let Inst{29-25} = rd2;

    let Inst{24-20} = rs2;

    let Inst{19-15} = rs1;

    let Inst{14-12} = 0b010;

    let Inst{11-7} = rd;

    let Inst{6-0} = 0b0101011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "mac_ld_x2\t$rd, $rd2, $rs1, ${imm2}(${rs2})";

    // Constraints
    let Constraints = "$rd = $rd_wb, $rd2 = $rd2_wb";
}
def MAC_LD_X2 : RVInst_MAC_LD_X2<(outs GPR:$rd_wb, GPR:$rd2_wb), (ins GPR:$rd, GPR:$rd2, GPR:$rs1, uimm2:$imm2, GPR:$rs2)>;

}
