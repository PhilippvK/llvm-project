#include <stdio.h>
#include <stdint.h>
#include <riscv_vector.h>


#define SIZE 16


/*

Storage formats
Element packing in input tiles

For non-widening multiply-accumulate instructions (W=1), the input elements A and B have the same width as the accumulator (SEW), and no packing occurs.

For widening multiply-accumulate instructions (W>1), each input register group holds elements at the effective input element width EEW = SEW ÷ W. Because tile load instructions always transfer data at SEW granularity, every loaded SEW-bit storage position contains W contiguous packed narrow elements that the multiply-accumulate instruction consumes as a sub-dot-product.
ime tile widening
Figure 3. Element distribution and tile geometry example for L=32, SEW wide elements (left), two SEW/2 wide elements packed per SEW (middle), and four SEW/4 wide elements per SEW (right). Widening by a factor W (with the corresponding packing of W narrow elements per SEW-wide slot) increases the effective K dimension of the tile by a factor of W.
Byte-sized and wider elements (EEW ≥ 8)

When the input element width is 8 bits or wider (EEW ∈ {8, 16, 32, 64}), the elements within the input register group follow standard RISC-V V element ordering: element k at width EEW occupies bits [k × EEW + EEW − 1 : k × EEW] of the register group. This is identical to the layout produced by a vector load at the same element width (e.g., vle8.v for EEW=8) and requires no special data preparation beyond the tile load itself.
Sub-byte elements (EEW = 4)

Four-bit input elements (OFP4 (E2M1), Int4) are packed two per byte in little-endian nibble order:

    The even-indexed element (element 2n) occupies the lower nibble [3:0] of byte n.

    The odd-indexed element (element 2n + 1) occupies the upper nibble [7:4] of byte n.

This extends the standard RISC-V V element-indexing convention to sub-byte widths: element k at width 4 occupies bits [4k + 3 : 4k] of the register group, consistent with the formula for all element widths.

Because tile loads operate at SEW (≥ 8 bits), each loaded byte already contains a naturally ordered pair of 4-bit elements. Software preparing input data in memory must pack adjacent elements within each byte accordingly.


Zvvmm: Extension for matrix multiplication on vector register groups interpreted as 2D integer matrix tiles

The Zvvmm family of extensions provides instructions that perform matrix multiply-accumulate on integer data, computing C ← C + A × BT, where A, B, and C are matrix tiles held in the vector register file.

The following table lists the integer matrix tile multiplication instructions. The arguments are:

    vd: Destination vector register group containing the C matrix tile.

    vs1: Source vector register group containing the A matrix tile.

    vs2: Source vector register group containing the BT matrix tile.

Mnemonic 	W 	A/B element width 	C element width

vmmacc.vv vd, vs1, vs2 1 SEW SEW

vwmmacc.vv vd, vs1, vs2 2 SEW/2 SEW

vqmmacc.vv vd, vs1, vs2 4 SEW/4 SEW

v8wmmacc.vv vd, vs1, vs2 8 SEW/8 SEW

Vector masking is not supported on matrix multiply-accumulate instructions: the vm bit in the encoding must be 1. For vmmacc.vv, vm=0 is reserved. For vwmmacc.vv, vqmmacc.vv, and v8wmmacc.vv, vm=0 encodes vfwimmacc.vv, vfqimmacc.vv, and vf8wimmacc.vv respectively — integer-input, floating-point-accumulate, microscaled instructions (see Microscaling support (v0.scale) and Integer MX encoding map (vm=0)). For floating-point multiply-accumulate instructions, vm=0 enables microscaling (see Microscaling support (v0.scale)).

Matrix multiply-accumulate instructions can not be interrupted and resumed: they require vstart = 0 at the start of execution, and if vstart is non-zero when such an instruction begins, an illegal-instruction exception is raised.
Arithmetic Considerations
Integer accumulation

For integer multiply-accumulate instructions, all intermediate results are reduced modulo 2SEW. Because modular addition is both associative and commutative, the final result is uniquely defined regardless of the accumulation order or grouping factor.


*/


#define EMUL


#ifdef EMUL
static inline vuint8m1_t vmmacc_emul_u8(vuint8m1_t a,
                                        vuint8m1_t b,
                                        vuint8m1_t c,
                                        size_t vl)
{
    // Widen multiply
    vuint16m2_t prod = __riscv_vwmulu_vv_u16m2(a, b, vl);

    // Reduce to scalar
    vuint16m1_t sum = __riscv_vredsum_vs_u16m2_u16m1(
        prod,
        __riscv_vmv_v_x_u16m1(0, vl),
        vl
    );

    uint16_t s = __riscv_vmv_x_s_u16m1_u16(sum);

    // Accumulate into c (broadcast add, modulo 2^8)
    vuint8m1_t acc = __riscv_vmv_v_x_u8m1((uint8_t)s, vl);
    return __riscv_vadd_vv_u8m1(c, acc, vl);
}
#endif // EMUL

int test_zvvmm(vuint8m1_t a, vuint8m1_t b) {

    size_t vl = __riscv_vsetvl_e8m1(SIZE);

    // Initialize accumulator to 0
    vuint8m1_t c = __riscv_vmv_v_x_u8m1(0, vl);

#ifdef EMUL
    c = vmmacc_emul_u8(a, b, c, vl);
#else
    asm volatile ("vmmacc.vv %[vd], %[vs1], %[vs2]" : [vd] "+vr"(c) : [vs1] "vr"(a), [vs2] "vr"(b) : );
#endif // EMUL

    // Widen to u16 for safe reduction
    vuint16m2_t c_wide = __riscv_vwcvtu_x_x_v_u16m2(c, vl);

    // Reduce sum
    vuint16m1_t sum = __riscv_vredsum_vs_u16m2_u16m1(c_wide,
                                            __riscv_vmv_v_x_u16m1(0, vl),
                                            vl);

    // Extract scalar
    int checksum = __riscv_vmv_x_s_u16m1_u16(sum);
    return checksum;
}


int main() {
    printf("Hello World!\n");

    size_t vl = __riscv_vsetvl_e8m1(SIZE);
    printf("vl=%u\n", vl);

    // a = [1,2,3,...]
    uint8_t data[SIZE];
    for (int i = 0; i < SIZE; i++) {
        data[i] = i + 1;
    }
    vuint8m1_t a = __riscv_vle8_v_u8m1(data, vl);

    // b = constant vector (all 1s)
    uint8_t constant = 1;
    vuint8m1_t b = __riscv_vmv_v_x_u8m1(constant, vl);

    int checksum = test_zvvmm(a, b);
    printf("checksum=%d\n", checksum);

    int expected = 0;
    for (int i = 0; i < SIZE; i++) {
        expected += data[i] * constant;
    }

    int ret = checksum == expected;
    printf("ret=%d\n", ret);

    return ret;
}
