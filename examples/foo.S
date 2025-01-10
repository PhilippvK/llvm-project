	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p1_m2p0_c2p0"
	.file	"foo.c"
	.globl	foo                             # -- Begin function foo
	.p2align	1
	.type	foo,@function
foo:                                    # @foo
	.cfi_startproc
# %bb.0:                                # %entry
	blt	a0, a1, .LBB0_2
# %bb.1:                                # %entry
	mv	a0, a1
.LBB0_2:                                # %entry
	ret
.Lfunc_end0:
	.size	foo, .Lfunc_end0-foo
	.cfi_endproc
                                        # -- End function
	.ident	"clang version 18.0.0 (https://github.com/llvm/llvm-project.git 19cdc0a13480806e474de6a7e6e200b1eccc7a13)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
