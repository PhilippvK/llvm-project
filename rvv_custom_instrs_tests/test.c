#include <stddef.h>
#include <stdint.h>
#include <riscv_vector.h>

#define N 256

// Uncomment this to use the custom fused add + shift-left instruction
// #define HAS_CUSTOM

#ifdef HAS_CUSTOM
void test_explicit(const int16_t *a, const int16_t *b, const int16_t *factors, int16_t *out) {
  size_t i = 0;
  size_t vl;

  for (; i < N; i += vl) {
    vl = __riscv_vsetvl_e16m1(N - i);

    // Load signed 16-bit vectors
    vint16m1_t va = __riscv_vle16_v_i16m1(&a[i], vl);
    vint16m1_t vb = __riscv_vle16_v_i16m1(&b[i], vl);
    vint16m1_t vf = __riscv_vle16_v_i16m1(&factors[i], vl);

    // Sign-extend 16-bit vectors to 32-bit vectors
    vint32m2_t va_wide = __riscv_vsext_vf2_i32m2(va, vl);
    vint32m2_t vb_wide = __riscv_vsext_vf2_i32m2(vb, vl);
    vint32m2_t vf_wide = __riscv_vsext_vf2_i32m2(vf, vl);

    // Compute sum (32-bit)
    // vint32m2_t sum = __riscv_vadd_vv_i32m2(va_wide, vb_wide, vl);

    // Multiply sum * factors (32-bit)
    // vint32m2_t prod = __riscv_vmul_vv_i32m2(sum, vf_wide, vl);
    vint32m2_t prod = __riscv_vaddmul_vv_i32m2(va_wide, vb_wide, vf_wide, vl);

    // Narrow result back to 16-bit with saturation
    // vint16m1_t vresult = __riscv_vnclip_wx_i16m1(prod, 0, vl);  // right-shift 0 bits + narrowing
    vint16m1_t vresult = __riscv_vnclip_wx_i16m1(prod, 0, __RISCV_VXRM_RNU, vl);  // shift right by 0 = just narrowing

    // Store signed 16-bit result
    __riscv_vse16_v_i16m1(&out[i], vresult, vl);
  }
}
#endif

void test_autovec(const uint16_t *a, const uint16_t *b, const uint16_t *factors, uint16_t *out) {
  for (size_t i = 0; i < N; ++i) {
    int16_t sum = (int16_t)a[i] + (int16_t)b[i];
    out[i] = (uint16_t)(sum * (int16_t)factors[i]);
  }
}


void test_baseline(const int16_t *a, const int16_t *b, const int16_t *factors, int16_t *out, size_t n) {
  size_t i = 0;
  size_t vl;

  while (i < n) {
    vl = __riscv_vsetvl_e16m1(n - i);

    vint16m1_t va = __riscv_vle16_v_i16m1(&a[i], vl);
    vint16m1_t vb = __riscv_vle16_v_i16m1(&b[i], vl);
    vint16m1_t vf = __riscv_vle16_v_i16m1(&factors[i], vl);

    // Widen inputs to 32-bit to avoid overflow
    vint32m2_t va_wide = __riscv_vsext_vf2_i32m2(va, vl);
    vint32m2_t vb_wide = __riscv_vsext_vf2_i32m2(vb, vl);
    vint32m2_t vf_wide = __riscv_vsext_vf2_i32m2(vf, vl);

    // sum = va + vb (32-bit)
    vint32m2_t vsum = __riscv_vadd_vv_i32m2(va_wide, vb_wide, vl);

    // prod = sum * factor (32-bit)
    vint32m2_t vprod = __riscv_vmul_vv_i32m2(vsum, vf_wide, vl);

    // Narrow back to 16-bit with saturation
    vint16m1_t vresult = __riscv_vnclip_wx_i16m1(vprod, 0, __RISCV_VXRM_RNU, vl);  // shift right by 0 = just narrowing

    __riscv_vse16_v_i16m1(&out[i], vresult, vl);

    i += vl;
  }
}
