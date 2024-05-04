# CDFG Extraction Task on (G)MIR Level

This file contains usage instructions for the `feature-pass-mir-cdfg-clean` branch.

## Disclaimer

The implementation is heavily inspired by https://github.com/AndHager/Sizalizer/tree/main/llvm-pass-plugin which implements similar functionality on LLVM-IR level.


## Prerequisites

Compile LLVM from source:

```sh
cmake -B build -S llvm/ -GNinja -DCMAKE_BUILD_TYPE=Release -DLLVM_BUILD_TOOLS=ON LLVM_ENABLE_ASSERTIONS=ON -DLLVM_OPTIMIZED_TABLEGEN=ON -DLLVM_ENABLE_PROJECTS="clang;lld" -DLLVM_TARGETS_TO_BUILD="X86;RISCV"
ninja -C build/ all
```

Start memgraph docker container:

```sh
docker run -p 7687:7687 -p 7444:7444 -p 3000:3000 --name memgraph memgraph/memgraph-platform
```


## Compiling Example Program

### RISC-V

An installation of the RISC-V GNU Tools (preferably non-multilib version) is required to run the following example.

```
./build/bin/clang notes/matmult.c -o out.elf --target=riscv32 --gcc-toolchain=/path/to/rv32gc_ilp32d -march=rv32gc -mabi=ilp32d --sysroot=/path/to/rv32gc_ilp32d/riscv32-unknown-elf -fuse-ld=lld -mllvm -global-isel=1 -c
```

### X86

Analogously the program can be build for X86 machines. (However, autovectorization needs to be disabled due to GlobalISel related crashes)

```
clang -o out.elf matmult.c -O3 -mllvm -global-isel=1 -c --target=x86_64 -fno-vectorize
```

### Analyzing Example Program (RISC-V only)

Connect to the web interface: `http://localhost:3000/`

**Optional:** Load custom Graph Style (see [`custom.gss`](./custom.gss)) for highlighting different functions and basic blocks in different colors.

1. Query all CFGs:

```
MATCH p0=(a)-[:CFG]->(b)
RETURN *;
```

*Output:* ![cfg1](https://github.com/PhilippvK/llvm-project/assets/7712605/60c2d497-525b-466e-83ac-119b76fb6595)


2. Query all DFGs:

```
MATCH p0=(a)-[:DFG]->(b)
RETURN *;
```

*Output:* ![dfg0](https://github.com/PhilippvK/llvm-project/assets/7712605/ed8b932b-881c-4f54-8092-7656311f8e5a)


3. Query DFG for a specific function and basic block:

```
MATCH p0=(a)-[:DFG]->(b)
WHERE a.func_name = "mat_mult" AND a.basic_block = "%bb.7"
RETURN *;
```

*Output:* ![dfg1](https://github.com/PhilippvK/llvm-project/assets/7712605/b8554bff-fb98-4541-839c-cbc2fc537548)



## Notes
- This pass should be target independent, but was so far only tested on RISC-V (`rv32im` and `rv32gc`).
- To run the pass based on GMIR instead of target-specific MIR, you have to manually edit `llvm/lib/Target/RISCV/RISCVTargetMachine.cpp` to move `addPass(new CDFGPass(getOptLevel()));` to an earlier stage.
- The stage where th pass is executed can be configured via `llvm/lib/CodeGen/TargetPassConfig.cpp`. However `#define CDFG_STAGE CDFG_STAGE_3` is tested so far...
- The (G)-MIR version unfortunately can not be build "out-of-tree" as it needs to be tightly integrated into the GlobalIsel Compilation Flow
- Due to the experimental state of GlobalISel (especially incomplete legalizations for RISC-V), some programs can not be compiled. This also affects this pass unless running it before the legalization stage.
- The `mgclient` library is not fullt integrated into the LLVM build system, hence you will need change the hardcoded paths in `/llvm/lib/CodeGen/GlobalISel/CMakeLists.txt` to point to match your system.
- Additionally `export LD_LIBRARY_PATH=/path/to/mgclient/build/src:$LD_LIBRARY_PATH` needs to be exported in the shell session during compilation and usage of LLVM.
- The pass does NOT cleanup the database automatically unless `#define PURGE_DB true` is enabled in `CDFGPass.cpp`.

## TODOs
- remove unnecessary `dbgs()` and `std::cout`!
- track liveins/liveouts between basic blocks (physical registers)
- properly handle `COPY` and `PHI` nodes
- make pass configurable via cli options
- allow choosing stage where pass should be executed
- add optional for automatic cleanup of database
- implement missing operand types:
  - [ ] MO_ShuffleMask
  - [ ] MO_Predicate
  - [ ] MO_IntrinsicID
  - [ ] MO_Metadata
  - [ ] MO_CFIIndex
  - [ ] MO_DbgInstrRef
  - [ ] MO_MCSymbol
  - [ ] MO_RegisterLiveOut
  - [ ] MO_RegisterMask
  - [ ] MO_BlockAddress
  - [ ] MO_ExternalSymbol
  - [ ] MO_JumpTableIndex
  - [ ] MO_TargetIndex
  - [ ] MO_ConstantPoolIndex

## Known Bugs

In `CDFG_STAGE_0` or lower, the following assertion is thrown:

```
clang: /tmp/llvm-project/llvm/include/llvm/CodeGen/MachineOperand.h:557: int64_t llvm::MachineOperand::getImm() const: Assertion `isImm() && "Wrong MachineOperand accessor"' failed.
```
