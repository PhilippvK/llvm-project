/*===---- riscv_corev_alu.h - CORE-V ALU intrinsics ------------------------===
 *
 * Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
 * See https://llvm.org/LICENSE.txt for license information.
 * SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
 *
 *===-----------------------------------------------------------------------===
 */

#ifndef __RISCV_XOPENASIP_BASE_H
#define __RISCV_XOPENASIP_BASE_H

#include <stdint.h>

#if defined(__cplusplus)
extern "C" {
#endif

// #if defined(__riscv_xopenasipbase)

#define __DEFAULT_FN_ATTRS __attribute__((__always_inline__, __nodebug__))

static __inline__ long __DEFAULT_FN_ATTRS __riscv_xopenasipbase_openasip_base_max(long a, long b) {
  return __builtin_riscv_xopenasipbase_openasip_base_max(a, b);
}

static __inline__ unsigned long __DEFAULT_FN_ATTRS
__riscv_xopenasipbase_openasip_base_maxu(unsigned long a, unsigned long b) {
  return __builtin_riscv_xopenasipbase_openasip_base_maxu(a, b);
}

// #endif // defined(__riscv_xopenasipbase)

#if defined(__cplusplus)
}
#endif

#endif // define __RISCV_XOPENASIP_BASE_H
