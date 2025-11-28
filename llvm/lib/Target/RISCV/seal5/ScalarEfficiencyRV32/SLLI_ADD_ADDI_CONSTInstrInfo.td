let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {
class RVInst_SLLI_ADD_ADDI_CONST<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd;
    bits<5> rs1;
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

    let Inst{23-19} = 0b00000;

    let Inst{18-14} = rs1;

    let Inst{13-9} = rd;

    let Inst{8-0} = 0b011010111;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "xexample.slli_add_addi_const\t$rd, $rs1, $imm, $imm2";

}
def SLLI_ADD_ADDI_CONST : RVInst_SLLI_ADD_ADDI_CONST<(outs GPR:$rd), (ins GPR:$rs1, simm3:$imm, uimm5:$imm2)>;
class Pat_SLLI_ADD_ADDI_CONST<SDPatternOperator OpNode, Instruction Inst>
: Pat<(OpNode GPR:$rs1, simm3:$imm, uimm5:$imm2), (Inst GPR:$rs1, simm3:$imm, uimm5:$imm2)>;
def : Pat_SLLI_ADD_ADDI_CONST<int_riscv_xscalarefficiencyrv32_xexample_slli_add_addi_const, SLLI_ADD_ADDI_CONST>;
}
