add_llvm_component_library(LLVMGlobalISel
  CSEInfo.cpp
  GISelKnownBits.cpp
  CSEMIRBuilder.cpp
  CallLowering.cpp
  GlobalISel.cpp
  Combiner.cpp
  CombinerHelper.cpp
  CombinerHelperVectorOps.cpp
  GIMatchTableExecutor.cpp
  GISelChangeObserver.cpp
  IRTranslator.cpp
  InlineAsmLowering.cpp
  InstructionSelect.cpp
  InstructionSelector.cpp
  LegalityPredicates.cpp
  LegalizeMutations.cpp
  Legalizer.cpp
  LegalizerHelper.cpp
  LegalizerInfo.cpp
  LegacyLegalizerInfo.cpp
  LoadStoreOpt.cpp
  Localizer.cpp
  LostDebugLocObserver.cpp
  MachineIRBuilder.cpp
  RegBankSelect.cpp
  Utils.cpp
  CDFGPass.cpp

  ADDITIONAL_HEADER_DIRS
  ${LLVM_MAIN_INCLUDE_DIR}/llvm/CodeGen/GlobalISel
  /work/git/sizalizer/mgclient/include/
  /work/git/sizalizer/mgclient/build/src/
  DEPENDS
  intrinsics_gen

  LINK_COMPONENTS
  Analysis
  CodeGen
  CodeGenTypes
  Core
  MC
  SelectionDAG
  Support
  Target
  TransformUtils
  )

TARGET_INCLUDE_DIRECTORIES(LLVMGlobalISel PUBLIC
  /work/git/sizalizer/mgclient/include/
  /work/git/sizalizer/mgclient/build/src/
)
TARGET_LINK_LIBRARIES(LLVMGlobalISel PUBLIC /usr/local/lib/libmgclient.so)
