	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p1_m2p0_c2p0"
	.file	"foo2.c"
	.globl	foo                             # -- Begin function foo
	.p2align	1
	.type	foo,@function
foo:                                    # @foo
	.cfi_startproc
# %bb.0:                                # %entry
	addi	sp, sp, -48
	.cfi_def_cfa_offset 48
	sw	ra, 44(sp)                      # 4-byte Folded Spill
	sw	s0, 40(sp)                      # 4-byte Folded Spill
	.cfi_offset ra, -4
	.cfi_offset s0, -8
	addi	s0, sp, 48
	.cfi_def_cfa s0, 0
                                        # kill: def $x14 killed $x13
                                        # kill: def $x14 killed $x12
                                        # kill: def $x14 killed $x11
                                        # kill: def $x14 killed $x10
	sw	a1, -12(s0)
	sw	a0, -16(s0)
	sw	a3, -20(s0)
	sw	a2, -24(s0)
	lw	a2, -16(s0)
	lw	a1, -12(s0)
	lw	a0, -24(s0)
	sll	a1, a1, a0
	not	a4, a0
	srli	a3, a2, 1
	srl	a3, a3, a4
	or	a1, a1, a3
	sll	a2, a2, a0
	sw	a2, -36(s0)                     # 4-byte Folded Spill
	addi	a0, a0, -32
	sw	a0, -32(s0)                     # 4-byte Folded Spill
	sw	a1, -28(s0)                     # 4-byte Folded Spill
	bltz	a0, .LBB0_2
# %bb.1:                                # %entry
	lw	a0, -36(s0)                     # 4-byte Folded Reload
	sw	a0, -28(s0)                     # 4-byte Folded Spill
.LBB0_2:                                # %entry
	lw	a2, -36(s0)                     # 4-byte Folded Reload
	lw	a0, -32(s0)                     # 4-byte Folded Reload
	lw	a1, -28(s0)                     # 4-byte Folded Reload
	srai	a0, a0, 31
	and	a0, a0, a2
	lw	ra, 44(sp)                      # 4-byte Folded Reload
	lw	s0, 40(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 48
	ret
.Lfunc_end0:
	.size	foo, .Lfunc_end0-foo
	.cfi_endproc
                                        # -- End function
	.ident	"clang version 18.0.0 (https://github.com/llvm/llvm-project.git 19cdc0a13480806e474de6a7e6e200b1eccc7a13)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
