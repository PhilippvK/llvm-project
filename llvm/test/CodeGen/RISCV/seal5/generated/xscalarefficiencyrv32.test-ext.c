; RUN: clang --print-supported-extensions | FileCheck --check-prefix CHECK %s

; CHECK: xscalarefficiencyrv32{{.*}}1.0 'XScalarEfficiencyRV32' (ScalarEfficiencyRV32 Extension)

