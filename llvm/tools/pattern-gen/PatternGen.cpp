#include "PatternGen.hpp"
#include "../lib/Target/RISCV/RISCVISelLowering.h"
#include "LLVMOverride.hpp"
#include "lib/InstrInfo.hpp"
#include "llvm/CodeGen/GlobalISel/PatternGen.h"
#include "llvm/CodeGen/ISDOpcodes.h"
#include "llvm/CodeGen/SelectionDAG.h"
#include "llvm/CodeGen/SelectionDAGNodes.h"
#include "llvm/IR/DebugLoc.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/CodeGen.h"
#include "llvm/Support/Errc.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/raw_ostream.h"
#include <array>
#include <exception>
#include <fstream>
#include <initializer_list>
#include <memory>
#include <optional>
#include <stdexcept>
#include <string>
#include <system_error>
#include <type_traits>
#include <unordered_map>
#include <utility>

int OptimizeBehavior(llvm::Module *M, std::vector<CDSLInstr> const &instrs,
                     std::ostream &ostreamIR, PGArgsStruct args) {
  // All other code in this file is called during code generation
  // by the LLVM pipeline. We thus "pass" arguments as globals.
  // llvm::PatternGenArgs::ExtName = &extName;

  int rv = RunOptPipeline(M, args.is64Bit, args.Mattr, args.OptLevel, ostreamIR);

  // llvm::PatternGenArgs::ExtName = nullptr;

  return rv;
}

int GeneratePatterns(llvm::Module *M, std::vector<CDSLInstr> const &instrs,
                     std::ostream &ostream, PGArgsStruct args) {
  // All other code in this file is called during code generation
  // by the LLVM pipeline. We thus "pass" arguments as globals.
  llvm::PatternGenArgs::OutStream = &ostream;
  llvm::PatternGenArgs::Args = args;
  llvm::PatternGenArgs::Instrs = &instrs;

  if (!args.Predicates.empty())
    ostream << "let Predicates = [" << args.Predicates << "] in {\n\n";

  int rv = RunPatternGenPipeline(M, args.is64Bit, args.Mattr);

  if (!args.Predicates.empty())
    ostream << "}\n";

  llvm::PatternGenArgs::OutStream = nullptr;
  llvm::PatternGenArgs::Args = PGArgsStruct();
  llvm::PatternGenArgs::Instrs = nullptr;

  return rv;
}

