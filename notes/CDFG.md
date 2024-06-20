# CDFG Extraction Task on (G)MIR Level

This file contains usage instructions for the `feature-pass-mir-cdfg-clean` branch.

## Disclaimer

The implementation is heavily inspired by https://github.com/AndHager/Sizalizer/tree/main/llvm-pass-plugin which implements similar functionality on LLVM-IR level.


## Prerequisites

Compile LLVM from source:

```sh
cmake -B build -S llvm/ -GNinja -DCMAKE_BUILD_TYPE=Release -DLLVM_BUILD_TOOLS=ON LLVM_ENABLE_ASSERTIONS=ON -DLLVM_OPTIMIZED_TABLEGEN=ON -DLLVM_ENABLE_PROJECTS=clang;lld -DLLVM_TARGETS_TO_BUILD=X86;RISCV
ninja -C build/ all
```

Start memgraph docker container:

```sh
docker run -p 7687:7687 -p 7444:7444 -p 3000:3000 --name memgraph memgraph/memgraph-platform
```

Connect to the web interface: `http://localhost:3000/`

## Example

### RISC-V

An installation of the RISC-V GNU Tools (preferably non-multilib version) is required to run the following example.

```
./build/bin/clang notes/matmult.c -o out.elf --target=riscv32 --gcc-toolchain=/path/to/rv32gc_ilp32d -march=rv32gc -mabi=ilp32d --sysroot=/path/to/rv32gc_ilp32d/riscv32-unknown-elf -fuse-ld=lld -mllvm -global-isel=1 -c
```

### X86

TODO: test with x86

## Notes
- This pass should be target independent, but was so far only tested on RISC-V (`rv32im` and `rv32gc`).
- To run the pass based on GMIR instead of target-specific MIR, you have to manually edit `llvm/lib/Target/RISCV/RISCVTargetMachine.cpp` to move `addPass(new CDFGPass(getOptLevel()));` to an earlier stage.
- The (G)-MIR version unfortunately can not be build "out-of-tree" as it needs to be tightly integrated into the GlobalIsel Compilation Flow
- Due to the experimental state of GlobalISel (especially incomplete legalizations for RISC-V), some programs can not be compiled. This also affects this pass unless running it before the legalization stage.
- The `mgclient` library is not fullt integrated into the LLVM build system, hence you will need change the hardcoded paths in `/llvm/lib/CodeGen/GlobalISel/CMakeLists.txt` to point to match your system.
- Additionally `export LD_LIBRARY_PATH=/path/to/mgclient/build/src:$LD_LIBRARY_PATH` needs to be exported in the shell session during compilation and usage of LLVM.
- TODO: remove unnecessary `dbgs()` and `std::cout`!
