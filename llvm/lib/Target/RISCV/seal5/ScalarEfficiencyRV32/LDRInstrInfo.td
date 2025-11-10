let Predicates = [HasStdExtXScalarEfficiencyRV32, IsRV32] in {
class RVInst_LDR<dag outs, dag ins> : Instruction, Sched<[]> {
    // General
    let Namespace = "RISCV";
    let Size = 4;
    bits<32> SoftFail = 0;
    bits<32> Inst;

    // Operands
    bits<5> rd;
    bits<5> rs1;
    bits<5> rs2;
    bits<5> imm;

    // Attributes
    let hasSideEffects = 0;
    let mayLoad = 1;
    let mayStore = 0;
    let isTerminator = 0;
    let isBranch = 0;

    // Encoding

    let Inst{31-30} = 0b00;

    let Inst{29-25} = imm;

    let Inst{24-20} = rs2;

    let Inst{19-15} = rs1;

    let Inst{14-12} = 0b010;

    let Inst{11-7} = rd;

    let Inst{6-0} = 0b0001011;

    dag OutOperandList = outs;
    dag InOperandList = ins;

    // Assembly
    let AsmString = "ldr\t$rd, $imm ${rs2}(${rs1})";

}
def LDR : RVInst_LDR<(outs GPR:$rd), (ins uimm5:$imm, GPR:$rs2, GPR:$rs1)>;

}
