let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {
class RVInst_SLLI_ADD_ADDI<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd;
    bits<5> rs1;
    bits<5> rs2;
    bits<5> imm2;
    bits<3> imm;

    // Attributes
    let hasSideEffects = 0;
    let mayLoad = 0;
    let mayStore = 0;
    let isTerminator = 0;

    // Encoding

    let Inst{31-29} = imm;

    let Inst{28-24} = imm2;

    let Inst{23-19} = rs2;

    let Inst{18-14} = rs1;

    let Inst{13-9} = rd;

    let Inst{8-0} = 0b001010111;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "xexample.slli_add_addi\t$rd, $rs1, $rs2, $imm, $imm2";

}
def SLLI_ADD_ADDI : RVInst_SLLI_ADD_ADDI<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, simm3:$imm, uimm5:$imm2)>;
class Pat_SLLI_ADD_ADDI<SDPatternOperator OpNode, Instruction Inst>
: Pat<(OpNode GPR:$rs1, GPR:$rs2, simm3:$imm, uimm5:$imm2), (Inst GPR:$rs1, GPR:$rs2, simm3:$imm, uimm5:$imm2)>;
def : Pat_SLLI_ADD_ADDI<int_riscv_xscalarefficiencyrv32_xexample_slli_add_addi, SLLI_ADD_ADDI>;
}
