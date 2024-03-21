//===-- RISCVFeatures.td - RISC-V Features and Extensions --*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// RISC-V subtarget features and instruction predicates.
//===----------------------------------------------------------------------===//

// Integer Extensions

def FeatureStdExtI
    : SubtargetFeature<"i", "HasStdExtI", "true",
                       "'I' (Base Integer Instruction Set)">;
def HasStdExtI : Predicate<"Subtarget->hasStdExtI()">,
                 AssemblerPredicate<(all_of FeatureStdExtI),
                                    "'I' (Base Integer Instruction Set)">;
def FeatureStdExtZic64b
    : SubtargetFeature<"zic64b", "HasStdExtZic64b", "true",
                       "'Zic64b' (Cache Block Size Is 64 Bytes)">;

def FeatureStdExtZicbom
    : SubtargetFeature<"zicbom", "HasStdExtZicbom", "true",
                       "'Zicbom' (Cache-Block Management Instructions)">;
def HasStdExtZicbom : Predicate<"Subtarget->hasStdExtZicbom()">,
                      AssemblerPredicate<(all_of FeatureStdExtZicbom),
                          "'Zicbom' (Cache-Block Management Instructions)">;

def FeatureStdExtZicbop
    : SubtargetFeature<"zicbop", "HasStdExtZicbop", "true",
                       "'Zicbop' (Cache-Block Prefetch Instructions)">;
def HasStdExtZicbop : Predicate<"Subtarget->hasStdExtZicbop()">,
                      AssemblerPredicate<(all_of FeatureStdExtZicbop),
                          "'Zicbop' (Cache-Block Prefetch Instructions)">;

def FeatureStdExtZicboz
    : SubtargetFeature<"zicboz", "HasStdExtZicboz", "true",
                       "'Zicboz' (Cache-Block Zero Instructions)">;
def HasStdExtZicboz : Predicate<"Subtarget->hasStdExtZicboz()">,
                      AssemblerPredicate<(all_of FeatureStdExtZicboz),
                          "'Zicboz' (Cache-Block Zero Instructions)">;

def FeatureStdExtZiccamoa
    : SubtargetFeature<"ziccamoa", "HasStdExtZiccamoa", "true",
                       "'Ziccamoa' (Main Memory Supports All Atomics in A)">;

def FeatureStdExtZiccif
    : SubtargetFeature<"ziccif", "HasStdExtZiccif", "true",
                       "'Ziccif' (Main Memory Supports Instruction Fetch with Atomicity Requirement)">;

def FeatureStdExtZicclsm
    : SubtargetFeature<"zicclsm", "HasStdExtZicclsm", "true",
                       "'Zicclsm' (Main Memory Supports Misaligned Loads/Stores)">;

def FeatureStdExtZiccrse
    : SubtargetFeature<"ziccrse", "HasStdExtZiccrse", "true",
                       "'Ziccrse' (Main Memory Supports Forward Progress on LR/SC Sequences)">;

def FeatureStdExtZicsr
    : SubtargetFeature<"zicsr", "HasStdExtZicsr", "true",
                       "'zicsr' (CSRs)">;
def HasStdExtZicsr : Predicate<"Subtarget->hasStdExtZicsr()">,
                     AssemblerPredicate<(all_of FeatureStdExtZicsr),
                                        "'Zicsr' (CSRs)">;

def FeatureStdExtZicntr
    : SubtargetFeature<"zicntr", "HasStdExtZicntr", "true",
                       "'Zicntr' (Base Counters and Timers)",
                       [FeatureStdExtZicsr]>;

def FeatureStdExtZicond
    : SubtargetFeature<"zicond", "HasStdExtZicond", "true",
                       "'Zicond' (Integer Conditional Operations)">;
def HasStdExtZicond : Predicate<"Subtarget->hasStdExtZicond()">,
                      AssemblerPredicate<(all_of FeatureStdExtZicond),
                          "'Zicond' (Integer Conditional Operations)">;

def FeatureStdExtZifencei
    : SubtargetFeature<"zifencei", "HasStdExtZifencei", "true",
                       "'Zifencei' (fence.i)">;
def HasStdExtZifencei : Predicate<"Subtarget->hasStdExtZifencei()">,
                        AssemblerPredicate<(all_of FeatureStdExtZifencei),
                                           "'Zifencei' (fence.i)">;

def FeatureStdExtZihintpause
    : SubtargetFeature<"zihintpause", "HasStdExtZihintpause", "true",
                       "'Zihintpause' (Pause Hint)">;
def HasStdExtZihintpause : Predicate<"Subtarget->hasStdExtZihintpause()">,
                           AssemblerPredicate<(all_of FeatureStdExtZihintpause),
                                              "'Zihintpause' (Pause Hint)">;

def FeatureStdExtZihintntl
    : SubtargetFeature<"zihintntl", "HasStdExtZihintntl", "true",
                       "'Zihintntl' (Non-Temporal Locality Hints)">;
def HasStdExtZihintntl : Predicate<"Subtarget->hasStdExtZihintntl()">,
                         AssemblerPredicate<(all_of FeatureStdExtZihintntl),
                             "'Zihintntl' (Non-Temporal Locality Hints)">;

def FeatureStdExtZihpm
    : SubtargetFeature<"zihpm", "HasStdExtZihpm", "true",
                       "'Zihpm' (Hardware Performance Counters)",
                       [FeatureStdExtZicsr]>;

def FeatureStdExtZimop : SubtargetFeature<"experimental-zimop", "HasStdExtZimop", "true",
                                          "'Zimop' (May-Be-Operations)">;
def HasStdExtZimop : Predicate<"Subtarget->hasStdExtZimop()">,
                     AssemblerPredicate<(all_of FeatureStdExtZimop),
                                        "'Zimop' (May-Be-Operations)">;

def FeatureStdExtZicfilp
    : SubtargetFeature<"experimental-zicfilp", "HasStdExtZicfilp", "true",
                       "'Zicfilp' (Landing pad)">;
def HasStdExtZicfilp : Predicate<"Subtarget->hasStdExtZicfilp()">,
                       AssemblerPredicate<(all_of FeatureStdExtZicfilp),
                                          "'Zicfilp' (Landing pad)">;

def FeatureStdExtZicfiss
    : SubtargetFeature<"experimental-zicfiss", "HasStdExtZicfiss", "true",
                       "'Zicfiss' (Shadow stack)",
                       [FeatureStdExtZicsr, FeatureStdExtZimop]>;
def HasStdExtZicfiss : Predicate<"Subtarget->hasStdExtZicfiss()">,
                       AssemblerPredicate<(all_of FeatureStdExtZicfiss),
                                          "'Zicfiss' (Shadow stack)">;
def NoHasStdExtZicfiss : Predicate<"!Subtarget->hasStdExtZicfiss()">;

// Multiply Extensions

def FeatureStdExtM
    : SubtargetFeature<"m", "HasStdExtM", "true",
                       "'M' (Integer Multiplication and Division)">;
def HasStdExtM : Predicate<"Subtarget->hasStdExtM()">,
                 AssemblerPredicate<(all_of FeatureStdExtM),
                     "'M' (Integer Multiplication and Division)">;

def FeatureStdExtZmmul
    : SubtargetFeature<"zmmul", "HasStdExtZmmul", "true",
                       "'Zmmul' (Integer Multiplication)">;

def HasStdExtMOrZmmul
    : Predicate<"Subtarget->hasStdExtM() || Subtarget->hasStdExtZmmul()">,
      AssemblerPredicate<(any_of FeatureStdExtM, FeatureStdExtZmmul),
                         "'M' (Integer Multiplication and Division) or "
                         "'Zmmul' (Integer Multiplication)">;

// Atomic Extensions

def FeatureStdExtA
    : SubtargetFeature<"a", "HasStdExtA", "true",
                       "'A' (Atomic Instructions)">;
def HasStdExtA : Predicate<"Subtarget->hasStdExtA()">,
                 AssemblerPredicate<(all_of FeatureStdExtA),
                                    "'A' (Atomic Instructions)">;

def FeatureStdExtZtso
    : SubtargetFeature<"experimental-ztso", "HasStdExtZtso", "true",
                       "'Ztso' (Memory Model - Total Store Order)">;
def HasStdExtZtso : Predicate<"Subtarget->hasStdExtZtso()">,
                    AssemblerPredicate<(all_of FeatureStdExtZtso),
                        "'Ztso' (Memory Model - Total Store Order)">;
def NotHasStdExtZtso : Predicate<"!Subtarget->hasStdExtZtso()">;

def FeatureStdExtZa64rs : SubtargetFeature<"za64rs", "HasStdExtZa64rs", "true",
                                           "'Za64rs' (Reservation Set Size of at Most 64 Bytes)">;

def FeatureStdExtZa128rs : SubtargetFeature<"za128rs", "HasStdExtZa128rs", "true",
                                            "'Za128rs' (Reservation Set Size of at Most 128 Bytes)">;

def FeatureStdExtZacas
    : SubtargetFeature<"experimental-zacas", "HasStdExtZacas", "true",
                       "'Zacas' (Atomic Compare-And-Swap Instructions)">;
def HasStdExtZacas : Predicate<"Subtarget->hasStdExtZacas()">,
                     AssemblerPredicate<(all_of FeatureStdExtZacas),
                         "'Zacas' (Atomic Compare-And-Swap Instructions)">;
def NoStdExtZacas : Predicate<"!Subtarget->hasStdExtZacas()">;

def FeatureStdExtZawrs : SubtargetFeature<"zawrs", "HasStdExtZawrs", "true",
                                          "'Zawrs' (Wait on Reservation Set)">;
def HasStdExtZawrs : Predicate<"Subtarget->hasStdExtZawrs()">,
                     AssemblerPredicate<(all_of FeatureStdExtZawrs),
                                        "'Zawrs' (Wait on Reservation Set)">;

// Floating Point Extensions

def FeatureStdExtF
    : SubtargetFeature<"f", "HasStdExtF", "true",
                       "'F' (Single-Precision Floating-Point)",
                       [FeatureStdExtZicsr]>;
def HasStdExtF : Predicate<"Subtarget->hasStdExtF()">,
                 AssemblerPredicate<(all_of FeatureStdExtF),
                                    "'F' (Single-Precision Floating-Point)">;

def FeatureStdExtD
    : SubtargetFeature<"d", "HasStdExtD", "true",
                       "'D' (Double-Precision Floating-Point)",
                       [FeatureStdExtF]>;
def HasStdExtD : Predicate<"Subtarget->hasStdExtD()">,
                 AssemblerPredicate<(all_of FeatureStdExtD),
                                    "'D' (Double-Precision Floating-Point)">;

def FeatureStdExtZfhmin
    : SubtargetFeature<"zfhmin", "HasStdExtZfhmin", "true",
                       "'Zfhmin' (Half-Precision Floating-Point Minimal)",
                       [FeatureStdExtF]>;
def HasStdExtZfhmin : Predicate<"Subtarget->hasStdExtZfhmin()">,
                      AssemblerPredicate<(all_of FeatureStdExtZfhmin),
                          "'Zfh' (Half-Precision Floating-Point) or "
                          "'Zfhmin' (Half-Precision Floating-Point Minimal)">;

def FeatureStdExtZfh
    : SubtargetFeature<"zfh", "HasStdExtZfh", "true",
                       "'Zfh' (Half-Precision Floating-Point)",
                       [FeatureStdExtZfhmin]>;
def HasStdExtZfh : Predicate<"Subtarget->hasStdExtZfh()">,
                   AssemblerPredicate<(all_of FeatureStdExtZfh),
                       "'Zfh' (Half-Precision Floating-Point)">;
def NoStdExtZfh : Predicate<"!Subtarget->hasStdExtZfh()">;

def FeatureStdExtZfbfmin
    : SubtargetFeature<"experimental-zfbfmin", "HasStdExtZfbfmin", "true",
                       "'Zfbfmin' (Scalar BF16 Converts)",
                       [FeatureStdExtF]>;
def HasStdExtZfbfmin : Predicate<"Subtarget->hasStdExtZfbfmin()">,
                       AssemblerPredicate<(all_of FeatureStdExtZfbfmin),
                                          "'Zfbfmin' (Scalar BF16 Converts)">;

def HasHalfFPLoadStoreMove
    : Predicate<"Subtarget->hasHalfFPLoadStoreMove()">,
      AssemblerPredicate<(any_of FeatureStdExtZfh, FeatureStdExtZfhmin,
                                 FeatureStdExtZfbfmin),
                         "'Zfh' (Half-Precision Floating-Point) or "
                                    "'Zfhmin' (Half-Precision Floating-Point Minimal) or "
                                    "'Zfbfmin' (Scalar BF16 Converts)">;

def FeatureStdExtZfa
    : SubtargetFeature<"zfa", "HasStdExtZfa", "true",
                       "'Zfa' (Additional Floating-Point)",
                       [FeatureStdExtF]>;
def HasStdExtZfa : Predicate<"Subtarget->hasStdExtZfa()">,
                   AssemblerPredicate<(all_of FeatureStdExtZfa),
                                      "'Zfa' (Additional Floating-Point)">;

def FeatureStdExtZfinx
    : SubtargetFeature<"zfinx", "HasStdExtZfinx", "true",
                       "'Zfinx' (Float in Integer)",
                       [FeatureStdExtZicsr]>;
def HasStdExtZfinx : Predicate<"Subtarget->hasStdExtZfinx()">,
                     AssemblerPredicate<(all_of FeatureStdExtZfinx),
                                        "'Zfinx' (Float in Integer)">;

def FeatureStdExtZdinx
    : SubtargetFeature<"zdinx", "HasStdExtZdinx", "true",
                       "'Zdinx' (Double in Integer)",
                       [FeatureStdExtZfinx]>;
def HasStdExtZdinx : Predicate<"Subtarget->hasStdExtZdinx()">,
                     AssemblerPredicate<(all_of FeatureStdExtZdinx),
                                        "'Zdinx' (Double in Integer)">;

def FeatureStdExtZhinxmin
    : SubtargetFeature<"zhinxmin", "HasStdExtZhinxmin", "true",
                       "'Zhinxmin' (Half Float in Integer Minimal)",
                       [FeatureStdExtZfinx]>;
def HasStdExtZhinxmin : Predicate<"Subtarget->hasStdExtZhinxmin()">,
                        AssemblerPredicate<(all_of FeatureStdExtZhinxmin),
                            "'Zhinx' (Half Float in Integer) or "
                            "'Zhinxmin' (Half Float in Integer Minimal)">;

def FeatureStdExtZhinx
    : SubtargetFeature<"zhinx", "HasStdExtZhinx", "true",
                       "'Zhinx' (Half Float in Integer)",
                       [FeatureStdExtZhinxmin]>;
def HasStdExtZhinx : Predicate<"Subtarget->hasStdExtZhinx()">,
                     AssemblerPredicate<(all_of FeatureStdExtZhinx),
                                        "'Zhinx' (Half Float in Integer)">;
def NoStdExtZhinx : Predicate<"!Subtarget->hasStdExtZhinx()">;

// Compressed Extensions

def FeatureStdExtC
    : SubtargetFeature<"c", "HasStdExtC", "true",
                       "'C' (Compressed Instructions)">;
def HasStdExtC : Predicate<"Subtarget->hasStdExtC()">,
                 AssemblerPredicate<(all_of FeatureStdExtC),
                                    "'C' (Compressed Instructions)">;

def FeatureNoRVCHints
    : SubtargetFeature<"no-rvc-hints", "EnableRVCHintInstrs", "false",
                       "Disable RVC Hint Instructions.">;
def HasRVCHints : Predicate<"Subtarget->enableRVCHintInstrs()">,
                  AssemblerPredicate<(all_of(not FeatureNoRVCHints)),
                                     "RVC Hint Instructions">;

def FeatureStdExtZca
    : SubtargetFeature<"zca", "HasStdExtZca", "true",
                       "'Zca' (part of the C extension, excluding compressed "
                       "floating point loads/stores)">;

def HasStdExtCOrZca
    : Predicate<"Subtarget->hasStdExtCOrZca()">,
      AssemblerPredicate<(any_of FeatureStdExtC, FeatureStdExtZca),
                         "'C' (Compressed Instructions) or "
                         "'Zca' (part of the C extension, excluding "
                         "compressed floating point loads/stores)">;

def FeatureStdExtZcb
    : SubtargetFeature<"zcb", "HasStdExtZcb", "true",
                       "'Zcb' (Compressed basic bit manipulation instructions)",
                       [FeatureStdExtZca]>;
def HasStdExtZcb : Predicate<"Subtarget->hasStdExtZcb()">,
                   AssemblerPredicate<(all_of FeatureStdExtZcb),
                       "'Zcb' (Compressed basic bit manipulation instructions)">;

def FeatureStdExtZcd
    : SubtargetFeature<"zcd", "HasStdExtZcd", "true",
                       "'Zcd' (Compressed Double-Precision Floating-Point Instructions)",
                       [FeatureStdExtZca]>;

def HasStdExtCOrZcd
    : Predicate<"Subtarget->hasStdExtC() || Subtarget->hasStdExtZcd()">,
      AssemblerPredicate<(any_of FeatureStdExtC, FeatureStdExtZcd),
                         "'C' (Compressed Instructions) or "
                         "'Zcd' (Compressed Double-Precision Floating-Point Instructions)">;

def FeatureStdExtZcf
    : SubtargetFeature<"zcf", "HasStdExtZcf", "true",
                       "'Zcf' (Compressed Single-Precision Floating-Point Instructions)",
                       [FeatureStdExtZca]>;

def FeatureStdExtZcmp
    : SubtargetFeature<"zcmp", "HasStdExtZcmp", "true",
                       "'Zcmp' (sequenced instuctions for code-size reduction)",
                       [FeatureStdExtZca]>;
def HasStdExtZcmp : Predicate<"Subtarget->hasStdExtZcmp() && !Subtarget->hasStdExtC()">,
                    AssemblerPredicate<(all_of FeatureStdExtZcmp),
                        "'Zcmp' (sequenced instuctions for code-size reduction)">;

def FeatureStdExtZcmt
    : SubtargetFeature<"zcmt", "HasStdExtZcmt", "true",
                       "'Zcmt' (table jump instuctions for code-size reduction)",
                       [FeatureStdExtZca, FeatureStdExtZicsr]>;
def HasStdExtZcmt : Predicate<"Subtarget->hasStdExtZcmt()">,
                           AssemblerPredicate<(all_of FeatureStdExtZcmt),
                           "'Zcmt' (table jump instuctions for code-size reduction)">;

def FeatureStdExtZce
    : SubtargetFeature<"zce", "HasStdExtZce", "true",
                       "'Zce' (Compressed extensions for microcontrollers)",
                       [FeatureStdExtZca, FeatureStdExtZcb, FeatureStdExtZcmp,
                        FeatureStdExtZcmt]>;

def HasStdExtCOrZcfOrZce
    : Predicate<"Subtarget->hasStdExtC() || Subtarget->hasStdExtZcf() "
                "Subtarget->hasStdExtZce()">,
      AssemblerPredicate<(any_of FeatureStdExtC, FeatureStdExtZcf,
                                 FeatureStdExtZce),
                         "'C' (Compressed Instructions) or "
                         "'Zcf' (Compressed Single-Precision Floating-Point Instructions)">;

def FeatureStdExtZcmop : SubtargetFeature<"experimental-zcmop", "HasStdExtZcmop", "true",
                                          "'Zcmop' (Compressed May-Be-Operations)",
                                          [FeatureStdExtZca]>;
def HasStdExtZcmop : Predicate<"Subtarget->hasStdExtZcmop()">,
                     AssemblerPredicate<(all_of FeatureStdExtZcmop),
                         "'Zcmop' (Compressed May-Be-Operations)">;

// Bitmanip Extensions

def FeatureStdExtZba
    : SubtargetFeature<"zba", "HasStdExtZba", "true",
                       "'Zba' (Address Generation Instructions)">;
def HasStdExtZba : Predicate<"Subtarget->hasStdExtZba()">,
                   AssemblerPredicate<(all_of FeatureStdExtZba),
                                      "'Zba' (Address Generation Instructions)">;
def NotHasStdExtZba : Predicate<"!Subtarget->hasStdExtZba()">;

def FeatureStdExtZbb
    : SubtargetFeature<"zbb", "HasStdExtZbb", "true",
                       "'Zbb' (Basic Bit-Manipulation)">;
def HasStdExtZbb : Predicate<"Subtarget->hasStdExtZbb()">,
                   AssemblerPredicate<(all_of FeatureStdExtZbb),
                                      "'Zbb' (Basic Bit-Manipulation)">;

def FeatureStdExtZbc
    : SubtargetFeature<"zbc", "HasStdExtZbc", "true",
                       "'Zbc' (Carry-Less Multiplication)">;
def HasStdExtZbc : Predicate<"Subtarget->hasStdExtZbc()">,
                   AssemblerPredicate<(all_of FeatureStdExtZbc),
                                      "'Zbc' (Carry-Less Multiplication)">;

def FeatureStdExtZbs
    : SubtargetFeature<"zbs", "HasStdExtZbs", "true",
                       "'Zbs' (Single-Bit Instructions)">;
def HasStdExtZbs : Predicate<"Subtarget->hasStdExtZbs()">,
                   AssemblerPredicate<(all_of FeatureStdExtZbs),
                                      "'Zbs' (Single-Bit Instructions)">;

// Bitmanip Extensions for Cryptography Extensions

def FeatureStdExtZbkb
    : SubtargetFeature<"zbkb", "HasStdExtZbkb", "true",
                       "'Zbkb' (Bitmanip instructions for Cryptography)">;
def HasStdExtZbkb : Predicate<"Subtarget->hasStdExtZbkb()">,
                    AssemblerPredicate<(all_of FeatureStdExtZbkb),
                        "'Zbkb' (Bitmanip instructions for Cryptography)">;

def FeatureStdExtZbkx
    : SubtargetFeature<"zbkx", "HasStdExtZbkx", "true",
                       "'Zbkx' (Crossbar permutation instructions)">;
def HasStdExtZbkx : Predicate<"Subtarget->hasStdExtZbkx()">,
                    AssemblerPredicate<(all_of FeatureStdExtZbkx),
                        "'Zbkx' (Crossbar permutation instructions)">;

def HasStdExtZbbOrZbkb
    : Predicate<"Subtarget->hasStdExtZbb() || Subtarget->hasStdExtZbkb()">,
      AssemblerPredicate<(any_of FeatureStdExtZbb, FeatureStdExtZbkb),
                         "'Zbb' (Basic Bit-Manipulation) or "
                         "'Zbkb' (Bitmanip instructions for Cryptography)">;

// The Carry-less multiply subextension for cryptography is a subset of basic
// carry-less multiply subextension. The former should be enabled if the latter
// is enabled.
def FeatureStdExtZbkc
    : SubtargetFeature<"zbkc", "HasStdExtZbkc", "true",
                       "'Zbkc' (Carry-less multiply instructions for "
                       "Cryptography)">;
def HasStdExtZbkc
    : Predicate<"Subtarget->hasStdExtZbkc()">,
      AssemblerPredicate<(all_of FeatureStdExtZbkc),
          "'Zbkc' (Carry-less multiply instructions for Cryptography)">;

def HasStdExtZbcOrZbkc
    : Predicate<"Subtarget->hasStdExtZbc() || Subtarget->hasStdExtZbkc()">,
      AssemblerPredicate<(any_of FeatureStdExtZbc, FeatureStdExtZbkc),
                         "'Zbc' (Carry-Less Multiplication) or "
                         "'Zbkc' (Carry-less multiply instructions "
                         "for Cryptography)">;

// Cryptography Extensions

def FeatureStdExtZknd
    : SubtargetFeature<"zknd", "HasStdExtZknd", "true",
                       "'Zknd' (NIST Suite: AES Decryption)">;
def HasStdExtZknd : Predicate<"Subtarget->hasStdExtZknd()">,
                    AssemblerPredicate<(all_of FeatureStdExtZknd),
                                       "'Zknd' (NIST Suite: AES Decryption)">;

def FeatureStdExtZkne
    : SubtargetFeature<"zkne", "HasStdExtZkne", "true",
                       "'Zkne' (NIST Suite: AES Encryption)">;
def HasStdExtZkne : Predicate<"Subtarget->hasStdExtZkne()">,
                    AssemblerPredicate<(all_of FeatureStdExtZkne),
                                       "'Zkne' (NIST Suite: AES Encryption)">;

// Some instructions belong to both Zknd and Zkne subextensions.
// They should be enabled if either has been specified.
def HasStdExtZkndOrZkne
    : Predicate<"Subtarget->hasStdExtZknd() || Subtarget->hasStdExtZkne()">,
      AssemblerPredicate<(any_of FeatureStdExtZknd, FeatureStdExtZkne),
                         "'Zknd' (NIST Suite: AES Decryption) or "
                         "'Zkne' (NIST Suite: AES Encryption)">;

def FeatureStdExtZknh
    : SubtargetFeature<"zknh", "HasStdExtZknh", "true",
                       "'Zknh' (NIST Suite: Hash Function Instructions)">;
def HasStdExtZknh : Predicate<"Subtarget->hasStdExtZknh()">,
                    AssemblerPredicate<(all_of FeatureStdExtZknh),
                        "'Zknh' (NIST Suite: Hash Function Instructions)">;

def FeatureStdExtZksed
    : SubtargetFeature<"zksed", "HasStdExtZksed", "true",
                       "'Zksed' (ShangMi Suite: SM4 Block Cipher Instructions)">;
def HasStdExtZksed : Predicate<"Subtarget->hasStdExtZksed()">,
                     AssemblerPredicate<(all_of FeatureStdExtZksed),
                         "'Zksed' (ShangMi Suite: SM4 Block Cipher Instructions)">;

def FeatureStdExtZksh
    : SubtargetFeature<"zksh", "HasStdExtZksh", "true",
                       "'Zksh' (ShangMi Suite: SM3 Hash Function Instructions)">;
def HasStdExtZksh : Predicate<"Subtarget->hasStdExtZksh()">,
                    AssemblerPredicate<(all_of FeatureStdExtZksh),
                        "'Zksh' (ShangMi Suite: SM3 Hash Function Instructions)">;

def FeatureStdExtZkr
    : SubtargetFeature<"zkr", "HasStdExtZkr", "true",
                       "'Zkr' (Entropy Source Extension)">;
def HasStdExtZkr : Predicate<"Subtarget->hasStdExtZkr()">,
                   AssemblerPredicate<(all_of FeatureStdExtZkr),
                                      "'Zkr' (Entropy Source Extension)">;

def FeatureStdExtZkn
    : SubtargetFeature<"zkn", "HasStdExtZkn", "true",
                       "'Zkn' (NIST Algorithm Suite)",
                       [FeatureStdExtZbkb,
                        FeatureStdExtZbkc,
                        FeatureStdExtZbkx,
                        FeatureStdExtZkne,
                        FeatureStdExtZknd,
                        FeatureStdExtZknh]>;

def FeatureStdExtZks
    : SubtargetFeature<"zks", "HasStdExtZks", "true",
                       "'Zks' (ShangMi Algorithm Suite)",
                       [FeatureStdExtZbkb,
                        FeatureStdExtZbkc,
                        FeatureStdExtZbkx,
                        FeatureStdExtZksed,
                        FeatureStdExtZksh]>;

def FeatureStdExtZkt
    : SubtargetFeature<"zkt", "HasStdExtZkt", "true",
                       "'Zkt' (Data Independent Execution Latency)">;

def FeatureStdExtZk
    : SubtargetFeature<"zk", "HasStdExtZk", "true",
                       "'Zk' (Standard scalar cryptography extension)",
                       [FeatureStdExtZkn,
                        FeatureStdExtZkr,
                        FeatureStdExtZkt]>;

// Vector Extensions

def FeatureStdExtZvl32b : SubtargetFeature<"zvl32b", "ZvlLen", "32",
                                           "'Zvl' (Minimum Vector Length) 32">;

foreach i = { 6-16 } in {
  defvar I = !shl(1, i);
  def FeatureStdExtZvl#I#b :
      SubtargetFeature<"zvl"#I#"b", "ZvlLen", !cast<string>(I),
                       "'Zvl' (Minimum Vector Length) "#I,
                       [!cast<SubtargetFeature>("FeatureStdExtZvl"#!srl(I, 1)#"b")]>;
}

def FeatureStdExtZve32x
    : SubtargetFeature<"zve32x", "HasStdExtZve32x", "true",
                       "'Zve32x' (Vector Extensions for Embedded Processors "
                       "with maximal 32 EEW)",
                       [FeatureStdExtZicsr, FeatureStdExtZvl32b]>;

def FeatureStdExtZve32f
    : SubtargetFeature<"zve32f", "HasStdExtZve32f", "true",
                       "'Zve32f' (Vector Extensions for Embedded Processors "
                       "with maximal 32 EEW and F extension)",
                       [FeatureStdExtZve32x, FeatureStdExtF]>;

def FeatureStdExtZve64x
    : SubtargetFeature<"zve64x", "HasStdExtZve64x", "true",
                       "'Zve64x' (Vector Extensions for Embedded Processors "
                       "with maximal 64 EEW)",
                       [FeatureStdExtZve32x, FeatureStdExtZvl64b]>;

def FeatureStdExtZve64f
    : SubtargetFeature<"zve64f", "HasStdExtZve64f", "true",
                       "'Zve64f' (Vector Extensions for Embedded Processors "
                       "with maximal 64 EEW and F extension)",
                       [FeatureStdExtZve32f, FeatureStdExtZve64x]>;

def FeatureStdExtZve64d
    : SubtargetFeature<"zve64d", "HasStdExtZve64d", "true",
                       "'Zve64d' (Vector Extensions for Embedded Processors "
                       "with maximal 64 EEW, F and D extension)",
                       [FeatureStdExtZve64f, FeatureStdExtD]>;

def FeatureStdExtV
    : SubtargetFeature<"v", "HasStdExtV", "true",
                       "'V' (Vector Extension for Application Processors)",
                       [FeatureStdExtZvl128b, FeatureStdExtZve64d]>;

def FeatureStdExtZvfbfmin
    : SubtargetFeature<"experimental-zvfbfmin", "HasStdExtZvfbfmin", "true",
                       "'Zvbfmin' (Vector BF16 Converts)",
                       [FeatureStdExtZve32f]>;
def HasStdExtZvfbfmin : Predicate<"Subtarget->hasStdExtZvfbfmin()">,
                        AssemblerPredicate<(all_of FeatureStdExtZvfbfmin),
                            "'Zvfbfmin' (Vector BF16 Converts)">;

def FeatureStdExtZvfbfwma
    : SubtargetFeature<"experimental-zvfbfwma", "HasStdExtZvfbfwma", "true",
                       "'Zvfbfwma' (Vector BF16 widening mul-add)",
                       [FeatureStdExtZvfbfmin, FeatureStdExtZfbfmin]>;
def HasStdExtZvfbfwma : Predicate<"Subtarget->hasStdExtZvfbfwma()">,
                        AssemblerPredicate<(all_of FeatureStdExtZvfbfwma),
                            "'Zvfbfwma' (Vector BF16 widening mul-add)">;

def FeatureStdExtZvfhmin
    : SubtargetFeature<"zvfhmin", "HasStdExtZvfhmin", "true",
                       "'Zvfhmin' (Vector Half-Precision Floating-Point Minimal)",
                       [FeatureStdExtZve32f]>;

def FeatureStdExtZvfh
    : SubtargetFeature<"zvfh", "HasStdExtZvfh", "true",
                       "'Zvfh' (Vector Half-Precision Floating-Point)",
                       [FeatureStdExtZvfhmin, FeatureStdExtZfhmin]>;

def HasStdExtZfhOrZvfh
    : Predicate<"Subtarget->hasStdExtZfh() || Subtarget->hasStdExtZvfh()">,
      AssemblerPredicate<(any_of FeatureStdExtZfh, FeatureStdExtZvfh),
                         "'Zfh' (Half-Precision Floating-Point) or "
                         "'Zvfh' (Vector Half-Precision Floating-Point)">;

// Vector Cryptography and Bitmanip Extensions

def FeatureStdExtZvkb
    : SubtargetFeature<"zvkb", "HasStdExtZvkb", "true",
                       "'Zvkb' (Vector Bit-manipulation used in Cryptography)">;
def HasStdExtZvkb : Predicate<"Subtarget->hasStdExtZvkb()">,
                    AssemblerPredicate<(all_of FeatureStdExtZvkb),
                        "'Zvkb' (Vector Bit-manipulation used in Cryptography)">;

def FeatureStdExtZvbb
    : SubtargetFeature<"zvbb", "HasStdExtZvbb", "true",
                       "'Zvbb' (Vector basic bit-manipulation instructions)",
                       [FeatureStdExtZvkb]>;
def HasStdExtZvbb : Predicate<"Subtarget->hasStdExtZvbb()">,
                    AssemblerPredicate<(all_of FeatureStdExtZvbb),
                        "'Zvbb' (Vector basic bit-manipulation instructions)">;

def FeatureStdExtZvbc
    : SubtargetFeature<"zvbc", "HasStdExtZvbc", "true",
                       "'Zvbc' (Vector Carryless Multiplication)">;
def HasStdExtZvbc : Predicate<"Subtarget->hasStdExtZvbc()">,
                    AssemblerPredicate<(all_of FeatureStdExtZvbc),
                        "'Zvbc' (Vector Carryless Multiplication)">;

def FeatureStdExtZvkg
    : SubtargetFeature<"zvkg", "HasStdExtZvkg", "true",
                       "'Zvkg' (Vector GCM instructions for Cryptography)">;
def HasStdExtZvkg : Predicate<"Subtarget->hasStdExtZvkg()">,
                    AssemblerPredicate<(all_of FeatureStdExtZvkg),
                        "'Zvkg' (Vector GCM instructions for Cryptography)">;

def FeatureStdExtZvkned
    : SubtargetFeature<"zvkned", "HasStdExtZvkned", "true",
                       "'Zvkned' (Vector AES Encryption & Decryption (Single Round))">;
def HasStdExtZvkned : Predicate<"Subtarget->hasStdExtZvkned()">,
                      AssemblerPredicate<(all_of FeatureStdExtZvkned),
                          "'Zvkned' (Vector AES Encryption & Decryption (Single Round))">;

def FeatureStdExtZvknha
    : SubtargetFeature<"zvknha", "HasStdExtZvknha", "true",
                       "'Zvknha' (Vector SHA-2 (SHA-256 only))">;
def HasStdExtZvknha : Predicate<"Subtarget->hasStdExtZvknha()">,
                      AssemblerPredicate<(all_of FeatureStdExtZvknha),
                          "'Zvknha' (Vector SHA-2 (SHA-256 only))">;

def FeatureStdExtZvknhb
    : SubtargetFeature<"zvknhb", "HasStdExtZvknhb", "true",
                       "'Zvknhb' (Vector SHA-2 (SHA-256 and SHA-512))",
                       [FeatureStdExtZve64x]>;
def HasStdExtZvknhb : Predicate<"Subtarget->hasStdExtZvknhb()">,
                      AssemblerPredicate<(all_of FeatureStdExtZvknhb),
                          "'Zvknhb' (Vector SHA-2 (SHA-256 and SHA-512))">;

def HasStdExtZvknhaOrZvknhb : Predicate<"Subtarget->hasStdExtZvknha() || Subtarget->hasStdExtZvknhb()">,
                              AssemblerPredicate<(any_of FeatureStdExtZvknha, FeatureStdExtZvknhb),
                                  "'Zvknha' or 'Zvknhb' (Vector SHA-2)">;

def FeatureStdExtZvksed
    : SubtargetFeature<"zvksed", "HasStdExtZvksed", "true",
                       "'Zvksed' (SM4 Block Cipher Instructions)">;
def HasStdExtZvksed : Predicate<"Subtarget->hasStdExtZvksed()">,
                      AssemblerPredicate<(all_of FeatureStdExtZvksed),
                          "'Zvksed' (SM4 Block Cipher Instructions)">;

def FeatureStdExtZvksh
    : SubtargetFeature<"zvksh", "HasStdExtZvksh", "true",
                       "'Zvksh' (SM3 Hash Function Instructions)">;
def HasStdExtZvksh : Predicate<"Subtarget->hasStdExtZvksh()">,
                     AssemblerPredicate<(all_of FeatureStdExtZvksh),
                         "'Zvksh' (SM3 Hash Function Instructions)">;

def FeatureStdExtZvkt
    : SubtargetFeature<"zvkt", "HasStdExtZvkt", "true",
                       "'Zvkt' (Vector Data-Independent Execution Latency)">;

// Zvk short-hand extensions

def FeatureStdExtZvkn
    : SubtargetFeature<"zvkn", "HasStdExtZvkn", "true",
                       "'Zvkn' (shorthand for 'Zvkned', 'Zvknhb', 'Zvkb', and "
                       "'Zvkt')",
                       [FeatureStdExtZvkned, FeatureStdExtZvknhb,
                        FeatureStdExtZvkb, FeatureStdExtZvkt]>;

def FeatureStdExtZvknc
    : SubtargetFeature<"zvknc", "HasStdExtZvknc", "true",
                       "'Zvknc' (shorthand for 'Zvknc' and 'Zvbc')",
                       [FeatureStdExtZvkn, FeatureStdExtZvbc]>;

def FeatureStdExtZvkng
    : SubtargetFeature<"zvkng", "HasStdExtZvkng", "true",
                       "'zvkng' (shorthand for 'Zvkn' and 'Zvkg')",
                       [FeatureStdExtZvkn, FeatureStdExtZvkg]>;

def FeatureStdExtZvks
    : SubtargetFeature<"zvks", "HasStdExtZvks", "true",
                       "'Zvks' (shorthand for 'Zvksed', 'Zvksh', 'Zvkb', and "
                       "'Zvkt')",
                       [FeatureStdExtZvksed, FeatureStdExtZvksh,
                        FeatureStdExtZvkb, FeatureStdExtZvkt]>;

def FeatureStdExtZvksc
    : SubtargetFeature<"zvksc", "HasStdExtZvksc", "true",
                       "'Zvksc' (shorthand for 'Zvks' and 'Zvbc')",
                       [FeatureStdExtZvks, FeatureStdExtZvbc]>;

def FeatureStdExtZvksg
    : SubtargetFeature<"zvksg", "HasStdExtZvksg", "true",
                       "'Zvksg' (shorthand for 'Zvks' and 'Zvkg')",
                       [FeatureStdExtZvks, FeatureStdExtZvkg]>;

// Vector instruction predicates

def HasVInstructions    : Predicate<"Subtarget->hasVInstructions()">,
      AssemblerPredicate<
          (any_of FeatureStdExtZve32x),
          "'V' (Vector Extension for Application Processors), 'Zve32x' "
          "(Vector Extensions for Embedded Processors)">;
def HasVInstructionsI64 : Predicate<"Subtarget->hasVInstructionsI64()">,
      AssemblerPredicate<
          (any_of FeatureStdExtZve64x),
          "'V' (Vector Extension for Application Processors) or 'Zve64x' "
          "(Vector Extensions for Embedded Processors)">;
def HasVInstructionsAnyF : Predicate<"Subtarget->hasVInstructionsAnyF()">,
      AssemblerPredicate<
          (any_of FeatureStdExtZve32f),
          "'V' (Vector Extension for Application Processors), 'Zve32f' "
          "(Vector Extensions for Embedded Processors)">;

def HasVInstructionsF16Minimal : Predicate<"Subtarget->hasVInstructionsF16Minimal()">,
      AssemblerPredicate<(any_of FeatureStdExtZvfhmin, FeatureStdExtZvfh),
                         "'Zvfhmin' (Vector Half-Precision Floating-Point Minimal) or "
                         "'Zvfh' (Vector Half-Precision Floating-Point)">;

def HasVInstructionsBF16 : Predicate<"Subtarget->hasVInstructionsBF16()">;
def HasVInstructionsF16 : Predicate<"Subtarget->hasVInstructionsF16()">;
def HasVInstructionsF64 : Predicate<"Subtarget->hasVInstructionsF64()">;

def HasVInstructionsFullMultiply : Predicate<"Subtarget->hasVInstructionsFullMultiply()">;

// Hypervisor Extensions

def FeatureStdExtH
    : SubtargetFeature<"h", "HasStdExtH", "true",
                       "'H' (Hypervisor)">;

def HasStdExtH : Predicate<"Subtarget->hasStdExtH()">,
                 AssemblerPredicate<(all_of FeatureStdExtH),
                                    "'H' (Hypervisor)">;

// Supervisor extensions

def FeatureStdExtSmaia
    : SubtargetFeature<"smaia", "HasStdExtSmaia", "true",
                       "'Smaia' (Advanced Interrupt Architecture Machine "
                       "Level)", []>;
def FeatureStdExtSsaia
    : SubtargetFeature<"ssaia", "HasStdExtSsaia", "true",
                       "'Ssaia' (Advanced Interrupt Architecture Supervisor "
                       "Level)", []>;

def FeatureStdExtSmepmp
    : SubtargetFeature<"smepmp", "HasStdExtSmepmp", "true",
                       "'Smepmp' (Enhanced Physical Memory Protection)", []>;

def FeatureStdExtSvinval
    : SubtargetFeature<"svinval", "HasStdExtSvinval", "true",
                       "'Svinval' (Fine-Grained Address-Translation Cache Invalidation)">;
def HasStdExtSvinval : Predicate<"Subtarget->hasStdExtSvinval()">,
                       AssemblerPredicate<(all_of FeatureStdExtSvinval),
                           "'Svinval' (Fine-Grained Address-Translation Cache Invalidation)">;

def FeatureGPR32V : SubtargetFeature<"gpr32v", "HasGPR32V", "true", "TODO">;
def HasGPR32V
   : Predicate<"Subtarget->hasGPR32V)">,
     AssemblerPredicate<(any_of FeatureGPR32V),
                        "'GPR32V' (TODO)">;

// RISCVFeatures.td - riscv_features - INSERTION_START
def FeatureVendorSeal5Testalucvabs8 : SubtargetFeature<"xseal5testalucvabs8", "HasVendorSeal5Testalucvabs8", "true", "'Seal5Testalucvabs8' (Seal5Test_alu_cv_abs8 Extension)">;

def HasVendorSeal5Testalucvabs8 : Predicate<"Subtarget->hasVendorSeal5Testalucvabs8()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvabs8), "'Seal5Testalucvabs8' (Seal5Test_alu_cv_abs8 Extension)">;
def FeatureVendorSeal5Testalucvabs16 : SubtargetFeature<"xseal5testalucvabs16", "HasVendorSeal5Testalucvabs16", "true", "'Seal5Testalucvabs16' (Seal5Test_alu_cv_abs16 Extension)">;

def HasVendorSeal5Testalucvabs16 : Predicate<"Subtarget->hasVendorSeal5Testalucvabs16()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvabs16), "'Seal5Testalucvabs16' (Seal5Test_alu_cv_abs16 Extension)">;
def FeatureVendorSeal5Testalucvabs32 : SubtargetFeature<"xseal5testalucvabs32", "HasVendorSeal5Testalucvabs32", "true", "'Seal5Testalucvabs32' (Seal5Test_alu_cv_abs32 Extension)">;

def HasVendorSeal5Testalucvabs32 : Predicate<"Subtarget->hasVendorSeal5Testalucvabs32()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvabs32), "'Seal5Testalucvabs32' (Seal5Test_alu_cv_abs32 Extension)">;
def FeatureVendorSeal5Testalucvexths : SubtargetFeature<"xseal5testalucvexths", "HasVendorSeal5Testalucvexths", "true", "'Seal5Testalucvexths' (Seal5Test_alu_cv_exths Extension)">;

def HasVendorSeal5Testalucvexths : Predicate<"Subtarget->hasVendorSeal5Testalucvexths()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvexths), "'Seal5Testalucvexths' (Seal5Test_alu_cv_exths Extension)">;
def FeatureVendorSeal5Testalucvexthz : SubtargetFeature<"xseal5testalucvexthz", "HasVendorSeal5Testalucvexthz", "true", "'Seal5Testalucvexthz' (Seal5Test_alu_cv_exthz Extension)">;

def HasVendorSeal5Testalucvexthz : Predicate<"Subtarget->hasVendorSeal5Testalucvexthz()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvexthz), "'Seal5Testalucvexthz' (Seal5Test_alu_cv_exthz Extension)">;
def FeatureVendorSeal5Testalucvextbs : SubtargetFeature<"xseal5testalucvextbs", "HasVendorSeal5Testalucvextbs", "true", "'Seal5Testalucvextbs' (Seal5Test_alu_cv_extbs Extension)">;

def HasVendorSeal5Testalucvextbs : Predicate<"Subtarget->hasVendorSeal5Testalucvextbs()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvextbs), "'Seal5Testalucvextbs' (Seal5Test_alu_cv_extbs Extension)">;
def FeatureVendorSeal5Testalucvextbz : SubtargetFeature<"xseal5testalucvextbz", "HasVendorSeal5Testalucvextbz", "true", "'Seal5Testalucvextbz' (Seal5Test_alu_cv_extbz Extension)">;

def HasVendorSeal5Testalucvextbz : Predicate<"Subtarget->hasVendorSeal5Testalucvextbz()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvextbz), "'Seal5Testalucvextbz' (Seal5Test_alu_cv_extbz Extension)">;
def FeatureVendorSeal5Testalucvmini516 : SubtargetFeature<"xseal5testalucvmini516", "HasVendorSeal5Testalucvmini516", "true", "'Seal5Testalucvmini516' (Seal5Test_alu_cv_mini5_16 Extension)">;

def HasVendorSeal5Testalucvmini516 : Predicate<"Subtarget->hasVendorSeal5Testalucvmini516()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvmini516), "'Seal5Testalucvmini516' (Seal5Test_alu_cv_mini5_16 Extension)">;
def FeatureVendorSeal5Testalucvmini532 : SubtargetFeature<"xseal5testalucvmini532", "HasVendorSeal5Testalucvmini532", "true", "'Seal5Testalucvmini532' (Seal5Test_alu_cv_mini5_32 Extension)">;

def HasVendorSeal5Testalucvmini532 : Predicate<"Subtarget->hasVendorSeal5Testalucvmini532()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvmini532), "'Seal5Testalucvmini532' (Seal5Test_alu_cv_mini5_32 Extension)">;
def FeatureVendorSeal5Testalucvmini1216 : SubtargetFeature<"xseal5testalucvmini1216", "HasVendorSeal5Testalucvmini1216", "true", "'Seal5Testalucvmini1216' (Seal5Test_alu_cv_mini12_16 Extension)">;

def HasVendorSeal5Testalucvmini1216 : Predicate<"Subtarget->hasVendorSeal5Testalucvmini1216()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvmini1216), "'Seal5Testalucvmini1216' (Seal5Test_alu_cv_mini12_16 Extension)">;
def FeatureVendorSeal5Testalucvmini1232 : SubtargetFeature<"xseal5testalucvmini1232", "HasVendorSeal5Testalucvmini1232", "true", "'Seal5Testalucvmini1232' (Seal5Test_alu_cv_mini12_32 Extension)">;

def HasVendorSeal5Testalucvmini1232 : Predicate<"Subtarget->hasVendorSeal5Testalucvmini1232()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvmini1232), "'Seal5Testalucvmini1232' (Seal5Test_alu_cv_mini12_32 Extension)">;
def FeatureVendorSeal5Testalucvmaxi516 : SubtargetFeature<"xseal5testalucvmaxi516", "HasVendorSeal5Testalucvmaxi516", "true", "'Seal5Testalucvmaxi516' (Seal5Test_alu_cv_maxi5_16 Extension)">;

def HasVendorSeal5Testalucvmaxi516 : Predicate<"Subtarget->hasVendorSeal5Testalucvmaxi516()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvmaxi516), "'Seal5Testalucvmaxi516' (Seal5Test_alu_cv_maxi5_16 Extension)">;
def FeatureVendorSeal5Testalucvmaxi532 : SubtargetFeature<"xseal5testalucvmaxi532", "HasVendorSeal5Testalucvmaxi532", "true", "'Seal5Testalucvmaxi532' (Seal5Test_alu_cv_maxi5_32 Extension)">;

def HasVendorSeal5Testalucvmaxi532 : Predicate<"Subtarget->hasVendorSeal5Testalucvmaxi532()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvmaxi532), "'Seal5Testalucvmaxi532' (Seal5Test_alu_cv_maxi5_32 Extension)">;
def FeatureVendorSeal5Testalucvmaxi1216 : SubtargetFeature<"xseal5testalucvmaxi1216", "HasVendorSeal5Testalucvmaxi1216", "true", "'Seal5Testalucvmaxi1216' (Seal5Test_alu_cv_maxi12_16 Extension)">;

def HasVendorSeal5Testalucvmaxi1216 : Predicate<"Subtarget->hasVendorSeal5Testalucvmaxi1216()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvmaxi1216), "'Seal5Testalucvmaxi1216' (Seal5Test_alu_cv_maxi12_16 Extension)">;
def FeatureVendorSeal5Testalucvmaxi1232 : SubtargetFeature<"xseal5testalucvmaxi1232", "HasVendorSeal5Testalucvmaxi1232", "true", "'Seal5Testalucvmaxi1232' (Seal5Test_alu_cv_maxi12_32 Extension)">;

def HasVendorSeal5Testalucvmaxi1232 : Predicate<"Subtarget->hasVendorSeal5Testalucvmaxi1232()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvmaxi1232), "'Seal5Testalucvmaxi1232' (Seal5Test_alu_cv_maxi12_32 Extension)">;
def FeatureVendorSeal5Testalucvminu8 : SubtargetFeature<"xseal5testalucvminu8", "HasVendorSeal5Testalucvminu8", "true", "'Seal5Testalucvminu8' (Seal5Test_alu_cv_min_u_8 Extension)">;

def HasVendorSeal5Testalucvminu8 : Predicate<"Subtarget->hasVendorSeal5Testalucvminu8()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvminu8), "'Seal5Testalucvminu8' (Seal5Test_alu_cv_min_u_8 Extension)">;
def FeatureVendorSeal5Testalucvmins8 : SubtargetFeature<"xseal5testalucvmins8", "HasVendorSeal5Testalucvmins8", "true", "'Seal5Testalucvmins8' (Seal5Test_alu_cv_min_s_8 Extension)">;

def HasVendorSeal5Testalucvmins8 : Predicate<"Subtarget->hasVendorSeal5Testalucvmins8()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvmins8), "'Seal5Testalucvmins8' (Seal5Test_alu_cv_min_s_8 Extension)">;
def FeatureVendorSeal5Testalucvminu16 : SubtargetFeature<"xseal5testalucvminu16", "HasVendorSeal5Testalucvminu16", "true", "'Seal5Testalucvminu16' (Seal5Test_alu_cv_min_u_16 Extension)">;

def HasVendorSeal5Testalucvminu16 : Predicate<"Subtarget->hasVendorSeal5Testalucvminu16()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvminu16), "'Seal5Testalucvminu16' (Seal5Test_alu_cv_min_u_16 Extension)">;
def FeatureVendorSeal5Testalucvmins16 : SubtargetFeature<"xseal5testalucvmins16", "HasVendorSeal5Testalucvmins16", "true", "'Seal5Testalucvmins16' (Seal5Test_alu_cv_min_s_16 Extension)">;

def HasVendorSeal5Testalucvmins16 : Predicate<"Subtarget->hasVendorSeal5Testalucvmins16()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvmins16), "'Seal5Testalucvmins16' (Seal5Test_alu_cv_min_s_16 Extension)">;
def FeatureVendorSeal5Testalucvminu32 : SubtargetFeature<"xseal5testalucvminu32", "HasVendorSeal5Testalucvminu32", "true", "'Seal5Testalucvminu32' (Seal5Test_alu_cv_min_u_32 Extension)">;

def HasVendorSeal5Testalucvminu32 : Predicate<"Subtarget->hasVendorSeal5Testalucvminu32()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvminu32), "'Seal5Testalucvminu32' (Seal5Test_alu_cv_min_u_32 Extension)">;
def FeatureVendorSeal5Testalucvmins32 : SubtargetFeature<"xseal5testalucvmins32", "HasVendorSeal5Testalucvmins32", "true", "'Seal5Testalucvmins32' (Seal5Test_alu_cv_min_s_32 Extension)">;

def HasVendorSeal5Testalucvmins32 : Predicate<"Subtarget->hasVendorSeal5Testalucvmins32()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvmins32), "'Seal5Testalucvmins32' (Seal5Test_alu_cv_min_s_32 Extension)">;
def FeatureVendorSeal5Testalucvmaxu8 : SubtargetFeature<"xseal5testalucvmaxu8", "HasVendorSeal5Testalucvmaxu8", "true", "'Seal5Testalucvmaxu8' (Seal5Test_alu_cv_max_u_8 Extension)">;

def HasVendorSeal5Testalucvmaxu8 : Predicate<"Subtarget->hasVendorSeal5Testalucvmaxu8()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvmaxu8), "'Seal5Testalucvmaxu8' (Seal5Test_alu_cv_max_u_8 Extension)">;
def FeatureVendorSeal5Testalucvmaxs8 : SubtargetFeature<"xseal5testalucvmaxs8", "HasVendorSeal5Testalucvmaxs8", "true", "'Seal5Testalucvmaxs8' (Seal5Test_alu_cv_max_s_8 Extension)">;

def HasVendorSeal5Testalucvmaxs8 : Predicate<"Subtarget->hasVendorSeal5Testalucvmaxs8()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvmaxs8), "'Seal5Testalucvmaxs8' (Seal5Test_alu_cv_max_s_8 Extension)">;
def FeatureVendorSeal5Testalucvmaxu16 : SubtargetFeature<"xseal5testalucvmaxu16", "HasVendorSeal5Testalucvmaxu16", "true", "'Seal5Testalucvmaxu16' (Seal5Test_alu_cv_max_u_16 Extension)">;

def HasVendorSeal5Testalucvmaxu16 : Predicate<"Subtarget->hasVendorSeal5Testalucvmaxu16()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvmaxu16), "'Seal5Testalucvmaxu16' (Seal5Test_alu_cv_max_u_16 Extension)">;
def FeatureVendorSeal5Testalucvmaxs16 : SubtargetFeature<"xseal5testalucvmaxs16", "HasVendorSeal5Testalucvmaxs16", "true", "'Seal5Testalucvmaxs16' (Seal5Test_alu_cv_max_s_16 Extension)">;

def HasVendorSeal5Testalucvmaxs16 : Predicate<"Subtarget->hasVendorSeal5Testalucvmaxs16()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvmaxs16), "'Seal5Testalucvmaxs16' (Seal5Test_alu_cv_max_s_16 Extension)">;
def FeatureVendorSeal5Testalucvmaxu32 : SubtargetFeature<"xseal5testalucvmaxu32", "HasVendorSeal5Testalucvmaxu32", "true", "'Seal5Testalucvmaxu32' (Seal5Test_alu_cv_max_u_32 Extension)">;

def HasVendorSeal5Testalucvmaxu32 : Predicate<"Subtarget->hasVendorSeal5Testalucvmaxu32()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvmaxu32), "'Seal5Testalucvmaxu32' (Seal5Test_alu_cv_max_u_32 Extension)">;
def FeatureVendorSeal5Testalucvmaxs32 : SubtargetFeature<"xseal5testalucvmaxs32", "HasVendorSeal5Testalucvmaxs32", "true", "'Seal5Testalucvmaxs32' (Seal5Test_alu_cv_max_s_32 Extension)">;

def HasVendorSeal5Testalucvmaxs32 : Predicate<"Subtarget->hasVendorSeal5Testalucvmaxs32()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvmaxs32), "'Seal5Testalucvmaxs32' (Seal5Test_alu_cv_max_s_32 Extension)">;
def FeatureVendorSeal5Testalucvsletui16 : SubtargetFeature<"xseal5testalucvsletui16", "HasVendorSeal5Testalucvsletui16", "true", "'Seal5Testalucvsletui16' (Seal5Test_alu_cv_sletu_i16 Extension)">;

def HasVendorSeal5Testalucvsletui16 : Predicate<"Subtarget->hasVendorSeal5Testalucvsletui16()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvsletui16), "'Seal5Testalucvsletui16' (Seal5Test_alu_cv_sletu_i16 Extension)">;
def FeatureVendorSeal5Testalucvsletsi16 : SubtargetFeature<"xseal5testalucvsletsi16", "HasVendorSeal5Testalucvsletsi16", "true", "'Seal5Testalucvsletsi16' (Seal5Test_alu_cv_slets_i16 Extension)">;

def HasVendorSeal5Testalucvsletsi16 : Predicate<"Subtarget->hasVendorSeal5Testalucvsletsi16()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvsletsi16), "'Seal5Testalucvsletsi16' (Seal5Test_alu_cv_slets_i16 Extension)">;
def FeatureVendorSeal5Testalucvsletui32 : SubtargetFeature<"xseal5testalucvsletui32", "HasVendorSeal5Testalucvsletui32", "true", "'Seal5Testalucvsletui32' (Seal5Test_alu_cv_sletu_i32 Extension)">;

def HasVendorSeal5Testalucvsletui32 : Predicate<"Subtarget->hasVendorSeal5Testalucvsletui32()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvsletui32), "'Seal5Testalucvsletui32' (Seal5Test_alu_cv_sletu_i32 Extension)">;
def FeatureVendorSeal5Testalucvsletsi32 : SubtargetFeature<"xseal5testalucvsletsi32", "HasVendorSeal5Testalucvsletsi32", "true", "'Seal5Testalucvsletsi32' (Seal5Test_alu_cv_slets_i32 Extension)">;

def HasVendorSeal5Testalucvsletsi32 : Predicate<"Subtarget->hasVendorSeal5Testalucvsletsi32()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testalucvsletsi32), "'Seal5Testalucvsletsi32' (Seal5Test_alu_cv_slets_i32 Extension)">;
def FeatureVendorSeal5TestalucvaddNrui16 : SubtargetFeature<"xseal5testalucvaddnrui16", "HasVendorSeal5TestalucvaddNrui16", "true", "'Seal5TestalucvaddNrui16' (Seal5Test_alu_cv_addNru_i16 Extension)">;

def HasVendorSeal5TestalucvaddNrui16 : Predicate<"Subtarget->hasVendorSeal5TestalucvaddNrui16()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvaddNrui16), "'Seal5TestalucvaddNrui16' (Seal5Test_alu_cv_addNru_i16 Extension)">;
def FeatureVendorSeal5TestalucvaddNrsi16 : SubtargetFeature<"xseal5testalucvaddnrsi16", "HasVendorSeal5TestalucvaddNrsi16", "true", "'Seal5TestalucvaddNrsi16' (Seal5Test_alu_cv_addNrs_i16 Extension)">;

def HasVendorSeal5TestalucvaddNrsi16 : Predicate<"Subtarget->hasVendorSeal5TestalucvaddNrsi16()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvaddNrsi16), "'Seal5TestalucvaddNrsi16' (Seal5Test_alu_cv_addNrs_i16 Extension)">;
def FeatureVendorSeal5TestalucvaddNrui32 : SubtargetFeature<"xseal5testalucvaddnrui32", "HasVendorSeal5TestalucvaddNrui32", "true", "'Seal5TestalucvaddNrui32' (Seal5Test_alu_cv_addNru_i32 Extension)">;

def HasVendorSeal5TestalucvaddNrui32 : Predicate<"Subtarget->hasVendorSeal5TestalucvaddNrui32()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvaddNrui32), "'Seal5TestalucvaddNrui32' (Seal5Test_alu_cv_addNru_i32 Extension)">;
def FeatureVendorSeal5TestalucvaddNrsi32 : SubtargetFeature<"xseal5testalucvaddnrsi32", "HasVendorSeal5TestalucvaddNrsi32", "true", "'Seal5TestalucvaddNrsi32' (Seal5Test_alu_cv_addNrs_i32 Extension)">;

def HasVendorSeal5TestalucvaddNrsi32 : Predicate<"Subtarget->hasVendorSeal5TestalucvaddNrsi32()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvaddNrsi32), "'Seal5TestalucvaddNrsi32' (Seal5Test_alu_cv_addNrs_i32 Extension)">;
def FeatureVendorSeal5TestalucvsubNrui16 : SubtargetFeature<"xseal5testalucvsubnrui16", "HasVendorSeal5TestalucvsubNrui16", "true", "'Seal5TestalucvsubNrui16' (Seal5Test_alu_cv_subNru_i16 Extension)">;

def HasVendorSeal5TestalucvsubNrui16 : Predicate<"Subtarget->hasVendorSeal5TestalucvsubNrui16()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvsubNrui16), "'Seal5TestalucvsubNrui16' (Seal5Test_alu_cv_subNru_i16 Extension)">;
def FeatureVendorSeal5TestalucvsubNrsi16 : SubtargetFeature<"xseal5testalucvsubnrsi16", "HasVendorSeal5TestalucvsubNrsi16", "true", "'Seal5TestalucvsubNrsi16' (Seal5Test_alu_cv_subNrs_i16 Extension)">;

def HasVendorSeal5TestalucvsubNrsi16 : Predicate<"Subtarget->hasVendorSeal5TestalucvsubNrsi16()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvsubNrsi16), "'Seal5TestalucvsubNrsi16' (Seal5Test_alu_cv_subNrs_i16 Extension)">;
def FeatureVendorSeal5TestalucvsubNrui32 : SubtargetFeature<"xseal5testalucvsubnrui32", "HasVendorSeal5TestalucvsubNrui32", "true", "'Seal5TestalucvsubNrui32' (Seal5Test_alu_cv_subNru_i32 Extension)">;

def HasVendorSeal5TestalucvsubNrui32 : Predicate<"Subtarget->hasVendorSeal5TestalucvsubNrui32()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvsubNrui32), "'Seal5TestalucvsubNrui32' (Seal5Test_alu_cv_subNru_i32 Extension)">;
def FeatureVendorSeal5TestalucvsubNrsi32 : SubtargetFeature<"xseal5testalucvsubnrsi32", "HasVendorSeal5TestalucvsubNrsi32", "true", "'Seal5TestalucvsubNrsi32' (Seal5Test_alu_cv_subNrs_i32 Extension)">;

def HasVendorSeal5TestalucvsubNrsi32 : Predicate<"Subtarget->hasVendorSeal5TestalucvsubNrsi32()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvsubNrsi32), "'Seal5TestalucvsubNrsi32' (Seal5Test_alu_cv_subNrs_i32 Extension)">;
def FeatureVendorSeal5TestalucvaddRNrui16 : SubtargetFeature<"xseal5testalucvaddrnrui16", "HasVendorSeal5TestalucvaddRNrui16", "true", "'Seal5TestalucvaddRNrui16' (Seal5Test_alu_cv_addRNru_i16 Extension)">;

def HasVendorSeal5TestalucvaddRNrui16 : Predicate<"Subtarget->hasVendorSeal5TestalucvaddRNrui16()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvaddRNrui16), "'Seal5TestalucvaddRNrui16' (Seal5Test_alu_cv_addRNru_i16 Extension)">;
def FeatureVendorSeal5TestalucvaddRNrsi16 : SubtargetFeature<"xseal5testalucvaddrnrsi16", "HasVendorSeal5TestalucvaddRNrsi16", "true", "'Seal5TestalucvaddRNrsi16' (Seal5Test_alu_cv_addRNrs_i16 Extension)">;

def HasVendorSeal5TestalucvaddRNrsi16 : Predicate<"Subtarget->hasVendorSeal5TestalucvaddRNrsi16()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvaddRNrsi16), "'Seal5TestalucvaddRNrsi16' (Seal5Test_alu_cv_addRNrs_i16 Extension)">;
def FeatureVendorSeal5TestalucvaddRNrui32 : SubtargetFeature<"xseal5testalucvaddrnrui32", "HasVendorSeal5TestalucvaddRNrui32", "true", "'Seal5TestalucvaddRNrui32' (Seal5Test_alu_cv_addRNru_i32 Extension)">;

def HasVendorSeal5TestalucvaddRNrui32 : Predicate<"Subtarget->hasVendorSeal5TestalucvaddRNrui32()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvaddRNrui32), "'Seal5TestalucvaddRNrui32' (Seal5Test_alu_cv_addRNru_i32 Extension)">;
def FeatureVendorSeal5TestalucvaddRNrsi32 : SubtargetFeature<"xseal5testalucvaddrnrsi32", "HasVendorSeal5TestalucvaddRNrsi32", "true", "'Seal5TestalucvaddRNrsi32' (Seal5Test_alu_cv_addRNrs_i32 Extension)">;

def HasVendorSeal5TestalucvaddRNrsi32 : Predicate<"Subtarget->hasVendorSeal5TestalucvaddRNrsi32()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvaddRNrsi32), "'Seal5TestalucvaddRNrsi32' (Seal5Test_alu_cv_addRNrs_i32 Extension)">;
def FeatureVendorSeal5TestalucvsubRNrui16 : SubtargetFeature<"xseal5testalucvsubrnrui16", "HasVendorSeal5TestalucvsubRNrui16", "true", "'Seal5TestalucvsubRNrui16' (Seal5Test_alu_cv_subRNru_i16 Extension)">;

def HasVendorSeal5TestalucvsubRNrui16 : Predicate<"Subtarget->hasVendorSeal5TestalucvsubRNrui16()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvsubRNrui16), "'Seal5TestalucvsubRNrui16' (Seal5Test_alu_cv_subRNru_i16 Extension)">;
def FeatureVendorSeal5TestalucvsubRNrsi16 : SubtargetFeature<"xseal5testalucvsubrnrsi16", "HasVendorSeal5TestalucvsubRNrsi16", "true", "'Seal5TestalucvsubRNrsi16' (Seal5Test_alu_cv_subRNrs_i16 Extension)">;

def HasVendorSeal5TestalucvsubRNrsi16 : Predicate<"Subtarget->hasVendorSeal5TestalucvsubRNrsi16()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvsubRNrsi16), "'Seal5TestalucvsubRNrsi16' (Seal5Test_alu_cv_subRNrs_i16 Extension)">;
def FeatureVendorSeal5TestalucvsubRNrui32 : SubtargetFeature<"xseal5testalucvsubrnrui32", "HasVendorSeal5TestalucvsubRNrui32", "true", "'Seal5TestalucvsubRNrui32' (Seal5Test_alu_cv_subRNru_i32 Extension)">;

def HasVendorSeal5TestalucvsubRNrui32 : Predicate<"Subtarget->hasVendorSeal5TestalucvsubRNrui32()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvsubRNrui32), "'Seal5TestalucvsubRNrui32' (Seal5Test_alu_cv_subRNru_i32 Extension)">;
def FeatureVendorSeal5TestalucvsubRNrsi32 : SubtargetFeature<"xseal5testalucvsubrnrsi32", "HasVendorSeal5TestalucvsubRNrsi32", "true", "'Seal5TestalucvsubRNrsi32' (Seal5Test_alu_cv_subRNrs_i32 Extension)">;

def HasVendorSeal5TestalucvsubRNrsi32 : Predicate<"Subtarget->hasVendorSeal5TestalucvsubRNrsi32()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvsubRNrsi32), "'Seal5TestalucvsubRNrsi32' (Seal5Test_alu_cv_subRNrs_i32 Extension)">;
def FeatureVendorSeal5TestalucvaddNu : SubtargetFeature<"xseal5testalucvaddnu", "HasVendorSeal5TestalucvaddNu", "true", "'Seal5TestalucvaddNu' (Seal5Test_alu_cv_addNu Extension)">;

def HasVendorSeal5TestalucvaddNu : Predicate<"Subtarget->hasVendorSeal5TestalucvaddNu()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvaddNu), "'Seal5TestalucvaddNu' (Seal5Test_alu_cv_addNu Extension)">;
def FeatureVendorSeal5TestalucvaddNs : SubtargetFeature<"xseal5testalucvaddns", "HasVendorSeal5TestalucvaddNs", "true", "'Seal5TestalucvaddNs' (Seal5Test_alu_cv_addNs Extension)">;

def HasVendorSeal5TestalucvaddNs : Predicate<"Subtarget->hasVendorSeal5TestalucvaddNs()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvaddNs), "'Seal5TestalucvaddNs' (Seal5Test_alu_cv_addNs Extension)">;
def FeatureVendorSeal5TestalucvsubNu : SubtargetFeature<"xseal5testalucvsubnu", "HasVendorSeal5TestalucvsubNu", "true", "'Seal5TestalucvsubNu' (Seal5Test_alu_cv_subNu Extension)">;

def HasVendorSeal5TestalucvsubNu : Predicate<"Subtarget->hasVendorSeal5TestalucvsubNu()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvsubNu), "'Seal5TestalucvsubNu' (Seal5Test_alu_cv_subNu Extension)">;
def FeatureVendorSeal5TestalucvsubNs : SubtargetFeature<"xseal5testalucvsubns", "HasVendorSeal5TestalucvsubNs", "true", "'Seal5TestalucvsubNs' (Seal5Test_alu_cv_subNs Extension)">;

def HasVendorSeal5TestalucvsubNs : Predicate<"Subtarget->hasVendorSeal5TestalucvsubNs()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvsubNs), "'Seal5TestalucvsubNs' (Seal5Test_alu_cv_subNs Extension)">;
def FeatureVendorSeal5TestalucvaddRNu : SubtargetFeature<"xseal5testalucvaddrnu", "HasVendorSeal5TestalucvaddRNu", "true", "'Seal5TestalucvaddRNu' (Seal5Test_alu_cv_addRNu Extension)">;

def HasVendorSeal5TestalucvaddRNu : Predicate<"Subtarget->hasVendorSeal5TestalucvaddRNu()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvaddRNu), "'Seal5TestalucvaddRNu' (Seal5Test_alu_cv_addRNu Extension)">;
def FeatureVendorSeal5TestalucvaddRNs : SubtargetFeature<"xseal5testalucvaddrns", "HasVendorSeal5TestalucvaddRNs", "true", "'Seal5TestalucvaddRNs' (Seal5Test_alu_cv_addRNs Extension)">;

def HasVendorSeal5TestalucvaddRNs : Predicate<"Subtarget->hasVendorSeal5TestalucvaddRNs()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvaddRNs), "'Seal5TestalucvaddRNs' (Seal5Test_alu_cv_addRNs Extension)">;
def FeatureVendorSeal5TestalucvsubRNu : SubtargetFeature<"xseal5testalucvsubrnu", "HasVendorSeal5TestalucvsubRNu", "true", "'Seal5TestalucvsubRNu' (Seal5Test_alu_cv_subRNu Extension)">;

def HasVendorSeal5TestalucvsubRNu : Predicate<"Subtarget->hasVendorSeal5TestalucvsubRNu()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvsubRNu), "'Seal5TestalucvsubRNu' (Seal5Test_alu_cv_subRNu Extension)">;
def FeatureVendorSeal5TestalucvsubRNs : SubtargetFeature<"xseal5testalucvsubrns", "HasVendorSeal5TestalucvsubRNs", "true", "'Seal5TestalucvsubRNs' (Seal5Test_alu_cv_subRNs Extension)">;

def HasVendorSeal5TestalucvsubRNs : Predicate<"Subtarget->hasVendorSeal5TestalucvsubRNs()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestalucvsubRNs), "'Seal5TestalucvsubRNs' (Seal5Test_alu_cv_subRNs Extension)">;
def FeatureVendorSeal5Testmaccvmacui16 : SubtargetFeature<"xseal5testmaccvmacui16", "HasVendorSeal5Testmaccvmacui16", "true", "'Seal5Testmaccvmacui16' (Seal5Test_mac_cv_macu_i16 Extension)">;

def HasVendorSeal5Testmaccvmacui16 : Predicate<"Subtarget->hasVendorSeal5Testmaccvmacui16()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testmaccvmacui16), "'Seal5Testmaccvmacui16' (Seal5Test_mac_cv_macu_i16 Extension)">;
def FeatureVendorSeal5Testmaccvmacsi16 : SubtargetFeature<"xseal5testmaccvmacsi16", "HasVendorSeal5Testmaccvmacsi16", "true", "'Seal5Testmaccvmacsi16' (Seal5Test_mac_cv_macs_i16 Extension)">;

def HasVendorSeal5Testmaccvmacsi16 : Predicate<"Subtarget->hasVendorSeal5Testmaccvmacsi16()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testmaccvmacsi16), "'Seal5Testmaccvmacsi16' (Seal5Test_mac_cv_macs_i16 Extension)">;
def FeatureVendorSeal5Testmaccvmacui32 : SubtargetFeature<"xseal5testmaccvmacui32", "HasVendorSeal5Testmaccvmacui32", "true", "'Seal5Testmaccvmacui32' (Seal5Test_mac_cv_macu_i32 Extension)">;

def HasVendorSeal5Testmaccvmacui32 : Predicate<"Subtarget->hasVendorSeal5Testmaccvmacui32()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testmaccvmacui32), "'Seal5Testmaccvmacui32' (Seal5Test_mac_cv_macu_i32 Extension)">;
def FeatureVendorSeal5Testmaccvmacsi32 : SubtargetFeature<"xseal5testmaccvmacsi32", "HasVendorSeal5Testmaccvmacsi32", "true", "'Seal5Testmaccvmacsi32' (Seal5Test_mac_cv_macs_i32 Extension)">;

def HasVendorSeal5Testmaccvmacsi32 : Predicate<"Subtarget->hasVendorSeal5Testmaccvmacsi32()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testmaccvmacsi32), "'Seal5Testmaccvmacsi32' (Seal5Test_mac_cv_macs_i32 Extension)">;
def FeatureVendorSeal5Testmaccvmsuui16 : SubtargetFeature<"xseal5testmaccvmsuui16", "HasVendorSeal5Testmaccvmsuui16", "true", "'Seal5Testmaccvmsuui16' (Seal5Test_mac_cv_msuu_i16 Extension)">;

def HasVendorSeal5Testmaccvmsuui16 : Predicate<"Subtarget->hasVendorSeal5Testmaccvmsuui16()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testmaccvmsuui16), "'Seal5Testmaccvmsuui16' (Seal5Test_mac_cv_msuu_i16 Extension)">;
def FeatureVendorSeal5Testmaccvmsusi16 : SubtargetFeature<"xseal5testmaccvmsusi16", "HasVendorSeal5Testmaccvmsusi16", "true", "'Seal5Testmaccvmsusi16' (Seal5Test_mac_cv_msus_i16 Extension)">;

def HasVendorSeal5Testmaccvmsusi16 : Predicate<"Subtarget->hasVendorSeal5Testmaccvmsusi16()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testmaccvmsusi16), "'Seal5Testmaccvmsusi16' (Seal5Test_mac_cv_msus_i16 Extension)">;
def FeatureVendorSeal5Testmaccvmsuui32 : SubtargetFeature<"xseal5testmaccvmsuui32", "HasVendorSeal5Testmaccvmsuui32", "true", "'Seal5Testmaccvmsuui32' (Seal5Test_mac_cv_msuu_i32 Extension)">;

def HasVendorSeal5Testmaccvmsuui32 : Predicate<"Subtarget->hasVendorSeal5Testmaccvmsuui32()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testmaccvmsuui32), "'Seal5Testmaccvmsuui32' (Seal5Test_mac_cv_msuu_i32 Extension)">;
def FeatureVendorSeal5Testmaccvmsusi32 : SubtargetFeature<"xseal5testmaccvmsusi32", "HasVendorSeal5Testmaccvmsusi32", "true", "'Seal5Testmaccvmsusi32' (Seal5Test_mac_cv_msus_i32 Extension)">;

def HasVendorSeal5Testmaccvmsusi32 : Predicate<"Subtarget->hasVendorSeal5Testmaccvmsusi32()">, AssemblerPredicate<(any_of FeatureVendorSeal5Testmaccvmsusi32), "'Seal5Testmaccvmsusi32' (Seal5Test_mac_cv_msus_i32 Extension)">;
def FeatureVendorSeal5TestmaccvmulNu : SubtargetFeature<"xseal5testmaccvmulnu", "HasVendorSeal5TestmaccvmulNu", "true", "'Seal5TestmaccvmulNu' (Seal5Test_mac_cv_mulNu Extension)">;

def HasVendorSeal5TestmaccvmulNu : Predicate<"Subtarget->hasVendorSeal5TestmaccvmulNu()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestmaccvmulNu), "'Seal5TestmaccvmulNu' (Seal5Test_mac_cv_mulNu Extension)">;
def FeatureVendorSeal5TestmaccvmulNs : SubtargetFeature<"xseal5testmaccvmulns", "HasVendorSeal5TestmaccvmulNs", "true", "'Seal5TestmaccvmulNs' (Seal5Test_mac_cv_mulNs Extension)">;

def HasVendorSeal5TestmaccvmulNs : Predicate<"Subtarget->hasVendorSeal5TestmaccvmulNs()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestmaccvmulNs), "'Seal5TestmaccvmulNs' (Seal5Test_mac_cv_mulNs Extension)">;
def FeatureVendorSeal5TestmaccvmulhhNu : SubtargetFeature<"xseal5testmaccvmulhhnu", "HasVendorSeal5TestmaccvmulhhNu", "true", "'Seal5TestmaccvmulhhNu' (Seal5Test_mac_cv_mulhhNu Extension)">;

def HasVendorSeal5TestmaccvmulhhNu : Predicate<"Subtarget->hasVendorSeal5TestmaccvmulhhNu()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestmaccvmulhhNu), "'Seal5TestmaccvmulhhNu' (Seal5Test_mac_cv_mulhhNu Extension)">;
def FeatureVendorSeal5TestmaccvmulhhNs : SubtargetFeature<"xseal5testmaccvmulhhns", "HasVendorSeal5TestmaccvmulhhNs", "true", "'Seal5TestmaccvmulhhNs' (Seal5Test_mac_cv_mulhhNs Extension)">;

def HasVendorSeal5TestmaccvmulhhNs : Predicate<"Subtarget->hasVendorSeal5TestmaccvmulhhNs()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestmaccvmulhhNs), "'Seal5TestmaccvmulhhNs' (Seal5Test_mac_cv_mulhhNs Extension)">;
def FeatureVendorSeal5TestmaccvmulRNu : SubtargetFeature<"xseal5testmaccvmulrnu", "HasVendorSeal5TestmaccvmulRNu", "true", "'Seal5TestmaccvmulRNu' (Seal5Test_mac_cv_mulRNu Extension)">;

def HasVendorSeal5TestmaccvmulRNu : Predicate<"Subtarget->hasVendorSeal5TestmaccvmulRNu()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestmaccvmulRNu), "'Seal5TestmaccvmulRNu' (Seal5Test_mac_cv_mulRNu Extension)">;
def FeatureVendorSeal5TestmaccvmulRNs : SubtargetFeature<"xseal5testmaccvmulrns", "HasVendorSeal5TestmaccvmulRNs", "true", "'Seal5TestmaccvmulRNs' (Seal5Test_mac_cv_mulRNs Extension)">;

def HasVendorSeal5TestmaccvmulRNs : Predicate<"Subtarget->hasVendorSeal5TestmaccvmulRNs()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestmaccvmulRNs), "'Seal5TestmaccvmulRNs' (Seal5Test_mac_cv_mulRNs Extension)">;
def FeatureVendorSeal5TestmaccvmulhhRNu : SubtargetFeature<"xseal5testmaccvmulhhrnu", "HasVendorSeal5TestmaccvmulhhRNu", "true", "'Seal5TestmaccvmulhhRNu' (Seal5Test_mac_cv_mulhhRNu Extension)">;

def HasVendorSeal5TestmaccvmulhhRNu : Predicate<"Subtarget->hasVendorSeal5TestmaccvmulhhRNu()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestmaccvmulhhRNu), "'Seal5TestmaccvmulhhRNu' (Seal5Test_mac_cv_mulhhRNu Extension)">;
def FeatureVendorSeal5TestmaccvmulhhRNs : SubtargetFeature<"xseal5testmaccvmulhhrns", "HasVendorSeal5TestmaccvmulhhRNs", "true", "'Seal5TestmaccvmulhhRNs' (Seal5Test_mac_cv_mulhhRNs Extension)">;

def HasVendorSeal5TestmaccvmulhhRNs : Predicate<"Subtarget->hasVendorSeal5TestmaccvmulhhRNs()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestmaccvmulhhRNs), "'Seal5TestmaccvmulhhRNs' (Seal5Test_mac_cv_mulhhRNs Extension)">;
def FeatureVendorSeal5TestmaccvmacNu : SubtargetFeature<"xseal5testmaccvmacnu", "HasVendorSeal5TestmaccvmacNu", "true", "'Seal5TestmaccvmacNu' (Seal5Test_mac_cv_macNu Extension)">;

def HasVendorSeal5TestmaccvmacNu : Predicate<"Subtarget->hasVendorSeal5TestmaccvmacNu()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestmaccvmacNu), "'Seal5TestmaccvmacNu' (Seal5Test_mac_cv_macNu Extension)">;
def FeatureVendorSeal5TestmaccvmacNs : SubtargetFeature<"xseal5testmaccvmacns", "HasVendorSeal5TestmaccvmacNs", "true", "'Seal5TestmaccvmacNs' (Seal5Test_mac_cv_macNs Extension)">;

def HasVendorSeal5TestmaccvmacNs : Predicate<"Subtarget->hasVendorSeal5TestmaccvmacNs()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestmaccvmacNs), "'Seal5TestmaccvmacNs' (Seal5Test_mac_cv_macNs Extension)">;
def FeatureVendorSeal5TestmaccvmachhNu : SubtargetFeature<"xseal5testmaccvmachhnu", "HasVendorSeal5TestmaccvmachhNu", "true", "'Seal5TestmaccvmachhNu' (Seal5Test_mac_cv_machhNu Extension)">;

def HasVendorSeal5TestmaccvmachhNu : Predicate<"Subtarget->hasVendorSeal5TestmaccvmachhNu()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestmaccvmachhNu), "'Seal5TestmaccvmachhNu' (Seal5Test_mac_cv_machhNu Extension)">;
def FeatureVendorSeal5TestmaccvmachhNs : SubtargetFeature<"xseal5testmaccvmachhns", "HasVendorSeal5TestmaccvmachhNs", "true", "'Seal5TestmaccvmachhNs' (Seal5Test_mac_cv_machhNs Extension)">;

def HasVendorSeal5TestmaccvmachhNs : Predicate<"Subtarget->hasVendorSeal5TestmaccvmachhNs()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestmaccvmachhNs), "'Seal5TestmaccvmachhNs' (Seal5Test_mac_cv_machhNs Extension)">;
def FeatureVendorSeal5TestmaccvmacRNu : SubtargetFeature<"xseal5testmaccvmacrnu", "HasVendorSeal5TestmaccvmacRNu", "true", "'Seal5TestmaccvmacRNu' (Seal5Test_mac_cv_macRNu Extension)">;

def HasVendorSeal5TestmaccvmacRNu : Predicate<"Subtarget->hasVendorSeal5TestmaccvmacRNu()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestmaccvmacRNu), "'Seal5TestmaccvmacRNu' (Seal5Test_mac_cv_macRNu Extension)">;
def FeatureVendorSeal5TestmaccvmacRNs : SubtargetFeature<"xseal5testmaccvmacrns", "HasVendorSeal5TestmaccvmacRNs", "true", "'Seal5TestmaccvmacRNs' (Seal5Test_mac_cv_macRNs Extension)">;

def HasVendorSeal5TestmaccvmacRNs : Predicate<"Subtarget->hasVendorSeal5TestmaccvmacRNs()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestmaccvmacRNs), "'Seal5TestmaccvmacRNs' (Seal5Test_mac_cv_macRNs Extension)">;
def FeatureVendorSeal5TestmaccvmachhRNu : SubtargetFeature<"xseal5testmaccvmachhrnu", "HasVendorSeal5TestmaccvmachhRNu", "true", "'Seal5TestmaccvmachhRNu' (Seal5Test_mac_cv_machhRNu Extension)">;

def HasVendorSeal5TestmaccvmachhRNu : Predicate<"Subtarget->hasVendorSeal5TestmaccvmachhRNu()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestmaccvmachhRNu), "'Seal5TestmaccvmachhRNu' (Seal5Test_mac_cv_machhRNu Extension)">;
def FeatureVendorSeal5TestmaccvmachhRNs : SubtargetFeature<"xseal5testmaccvmachhrns", "HasVendorSeal5TestmaccvmachhRNs", "true", "'Seal5TestmaccvmachhRNs' (Seal5Test_mac_cv_machhRNs Extension)">;

def HasVendorSeal5TestmaccvmachhRNs : Predicate<"Subtarget->hasVendorSeal5TestmaccvmachhRNs()">, AssemblerPredicate<(any_of FeatureVendorSeal5TestmaccvmachhRNs), "'Seal5TestmaccvmachhRNs' (Seal5Test_mac_cv_machhRNs Extension)">;

// RISCVFeatures.td - riscv_features - INSERTION_END

def FeatureStdExtSvnapot
    : SubtargetFeature<"svnapot", "HasStdExtSvnapot", "true",
                       "'Svnapot' (NAPOT Translation Contiguity)">;

def FeatureStdExtSvpbmt
    : SubtargetFeature<"svpbmt", "HasStdExtSvpbmt", "true",
                       "'Svpbmt' (Page-Based Memory Types)">;

//===----------------------------------------------------------------------===//
// Vendor extensions
//===----------------------------------------------------------------------===//

// Ventana Extenions

def FeatureVendorXVentanaCondOps
    : SubtargetFeature<"xventanacondops", "HasVendorXVentanaCondOps", "true",
                       "'XVentanaCondOps' (Ventana Conditional Ops)">;
def HasVendorXVentanaCondOps : Predicate<"Subtarget->hasVendorXVentanaCondOps()">,
                               AssemblerPredicate<(all_of FeatureVendorXVentanaCondOps),
                                   "'XVentanaCondOps' (Ventana Conditional Ops)">;

// T-Head Extensions

def FeatureVendorXTHeadBa
    : SubtargetFeature<"xtheadba", "HasVendorXTHeadBa", "true",
                       "'xtheadba' (T-Head address calculation instructions)">;
def HasVendorXTHeadBa : Predicate<"Subtarget->hasVendorXTHeadBa()">,
                        AssemblerPredicate<(all_of FeatureVendorXTHeadBa),
                            "'xtheadba' (T-Head address calculation instructions)">;

def FeatureVendorXTHeadBb
    : SubtargetFeature<"xtheadbb", "HasVendorXTHeadBb", "true",
                       "'xtheadbb' (T-Head basic bit-manipulation instructions)">;
def HasVendorXTHeadBb : Predicate<"Subtarget->hasVendorXTHeadBb()">,
                        AssemblerPredicate<(all_of FeatureVendorXTHeadBb),
                            "'xtheadbb' (T-Head basic bit-manipulation instructions)">;

def FeatureVendorXTHeadBs
    : SubtargetFeature<"xtheadbs", "HasVendorXTHeadBs", "true",
                       "'xtheadbs' (T-Head single-bit instructions)">;
def HasVendorXTHeadBs : Predicate<"Subtarget->hasVendorXTHeadBs()">,
                        AssemblerPredicate<(all_of FeatureVendorXTHeadBs),
                            "'xtheadbs' (T-Head single-bit instructions)">;

def FeatureVendorXTHeadCondMov
    : SubtargetFeature<"xtheadcondmov", "HasVendorXTHeadCondMov", "true",
                       "'xtheadcondmov' (T-Head conditional move instructions)">;
def HasVendorXTHeadCondMov : Predicate<"Subtarget->hasVendorXTHeadCondMov()">,
                             AssemblerPredicate<(all_of FeatureVendorXTHeadCondMov),
                                 "'xtheadcondmov' (T-Head conditional move instructions)">;

def FeatureVendorXTHeadCmo
    : SubtargetFeature<"xtheadcmo", "HasVendorXTHeadCmo", "true",
                       "'xtheadcmo' (T-Head cache management instructions)">;
def HasVendorXTHeadCmo : Predicate<"Subtarget->hasVendorXTHeadCmo()">,
                         AssemblerPredicate<(all_of FeatureVendorXTHeadCmo),
                             "'xtheadcmo' (T-Head cache management instructions)">;

def FeatureVendorXTHeadFMemIdx
    : SubtargetFeature<"xtheadfmemidx", "HasVendorXTHeadFMemIdx", "true",
                       "'xtheadfmemidx' (T-Head FP Indexed Memory Operations)",
                       [FeatureStdExtF]>;
def HasVendorXTHeadFMemIdx : Predicate<"Subtarget->hasVendorXTHeadFMemIdx()">,
                             AssemblerPredicate<(all_of FeatureVendorXTHeadFMemIdx),
                                 "'xtheadfmemidx' (T-Head FP Indexed Memory Operations)">;

def FeatureVendorXTHeadMac
    : SubtargetFeature<"xtheadmac", "HasVendorXTHeadMac", "true",
                       "'xtheadmac' (T-Head Multiply-Accumulate Instructions)">;
def HasVendorXTHeadMac : Predicate<"Subtarget->hasVendorXTHeadMac()">,
                         AssemblerPredicate<(all_of FeatureVendorXTHeadMac),
                             "'xtheadmac' (T-Head Multiply-Accumulate Instructions)">;

def FeatureVendorXTHeadMemIdx
    : SubtargetFeature<"xtheadmemidx", "HasVendorXTHeadMemIdx", "true",
                       "'xtheadmemidx' (T-Head Indexed Memory Operations)">;
def HasVendorXTHeadMemIdx : Predicate<"Subtarget->hasVendorXTHeadMemIdx()">,
                            AssemblerPredicate<(all_of FeatureVendorXTHeadMemIdx),
                                "'xtheadmemidx' (T-Head Indexed Memory Operations)">;

def FeatureVendorXTHeadMemPair
    : SubtargetFeature<"xtheadmempair", "HasVendorXTHeadMemPair", "true",
                       "'xtheadmempair' (T-Head two-GPR Memory Operations)">;
def HasVendorXTHeadMemPair : Predicate<"Subtarget->hasVendorXTHeadMemPair()">,
                             AssemblerPredicate<(all_of FeatureVendorXTHeadMemPair),
                                 "'xtheadmempair' (T-Head two-GPR Memory Operations)">;

def FeatureVendorXTHeadSync
    : SubtargetFeature<"xtheadsync", "HasVendorXTHeadSync", "true",
                       "'xtheadsync' (T-Head multicore synchronization instructions)">;
def HasVendorXTHeadSync : Predicate<"Subtarget->hasVendorXTHeadSync()">,
                          AssemblerPredicate<(all_of FeatureVendorXTHeadSync),
                              "'xtheadsync' (T-Head multicore synchronization instructions)">;

def FeatureVendorXTHeadVdot
    : SubtargetFeature<"xtheadvdot", "HasVendorXTHeadVdot", "true",
                       "'xtheadvdot' (T-Head Vector Extensions for Dot)",
                       [FeatureStdExtV]>;
def HasVendorXTHeadVdot : Predicate<"Subtarget->hasVendorXTHeadVdot()">,
                          AssemblerPredicate<(all_of FeatureVendorXTHeadVdot),
                              "'xtheadvdot' (T-Head Vector Extensions for Dot)">;

// SiFive Extensions

def FeatureVendorXSfvcp
    : SubtargetFeature<"xsfvcp", "HasVendorXSfvcp", "true",
                       "'XSfvcp' (SiFive Custom Vector Coprocessor Interface Instructions)",
                       [FeatureStdExtZve32x]>;
def HasVendorXSfvcp : Predicate<"Subtarget->hasVendorXSfvcp()">,
                      AssemblerPredicate<(all_of FeatureVendorXSfvcp),
                          "'XSfvcp' (SiFive Custom Vector Coprocessor Interface Instructions)">;

def FeatureVendorXSfvqmaccdod
    : SubtargetFeature<"xsfvqmaccdod", "HasVendorXSfvqmaccdod", "true",
                       "'XSfvqmaccdod' (SiFive Int8 Matrix Multiplication Instructions (2-by-8 and 8-by-2))",
                       [FeatureStdExtZve32x]>;
def HasVendorXSfvqmaccdod
    : Predicate<"Subtarget->hasVendorXSfvqmaccdod()">,
      AssemblerPredicate<(all_of FeatureVendorXSfvqmaccdod),
                         "'XSfvqmaccdod' (SiFive Int8 Matrix Multiplication Instructions (2-by-8 and 8-by-2))">;

def FeatureVendorXSfvqmaccqoq
    : SubtargetFeature<"xsfvqmaccqoq", "HasVendorXSfvqmaccqoq", "true",
                       "'XSfvqmaccqoq' (SiFive Int8 Matrix Multiplication Instructions (4-by-8 and 8-by-4))",
                       [FeatureStdExtZve32x]>;
def HasVendorXSfvqmaccqoq
    : Predicate<"Subtarget->hasVendorXSfvqmaccqoq()">,
      AssemblerPredicate<(all_of FeatureVendorXSfvqmaccqoq),
                         "'XSfvqmaccqoq' (SiFive Int8 Matrix Multiplication Instructions (4-by-8 and 8-by-4))">;

def FeatureVendorXSfvfwmaccqqq
    : SubtargetFeature<"xsfvfwmaccqqq", "HasVendorXSfvfwmaccqqq", "true",
                       "'XSfvfwmaccqqq' (SiFive Matrix Multiply Accumulate Instruction and 4-by-4))",
                       [FeatureStdExtZve32f, FeatureStdExtZvfbfmin]>;
def HasVendorXSfvfwmaccqqq
    : Predicate<"Subtarget->hasVendorXSfvfwmaccqqq()">,
      AssemblerPredicate<(all_of FeatureVendorXSfvfwmaccqqq),
                         "'XSfvfwmaccqqq' (SiFive Matrix Multiply Accumulate Instruction and 4-by-4))">;

def FeatureVendorXSfvfnrclipxfqf
    : SubtargetFeature<"xsfvfnrclipxfqf", "HasVendorXSfvfnrclipxfqf", "true",
                       "'XSfvfnrclipxfqf' (SiFive FP32-to-int8 Ranged Clip Instructions)",
                       [FeatureStdExtZve32f]>;
def HasVendorXSfvfnrclipxfqf
    : Predicate<"Subtarget->hasVendorXSfvfnrclipxfqf()">,
      AssemblerPredicate<(all_of FeatureVendorXSfvfnrclipxfqf),
                         "'XSfvfnrclipxfqf' (SiFive FP32-to-int8 Ranged Clip Instructions)">;

// Core-V Extensions

def FeatureVendorXCVelw
   : SubtargetFeature<"xcvelw", "HasVendorXCVelw", "true",
                      "'XCVelw' (CORE-V Event Load Word)">;
def HasVendorXCVelw
   : Predicate<"Subtarget->hasVendorXCVelw()">,
     AssemblerPredicate<(any_of FeatureVendorXCVelw),
                        "'XCVelw' (CORE-V Event Load Word)">;

def FeatureVendorXCVbitmanip
    : SubtargetFeature<"xcvbitmanip", "HasVendorXCVbitmanip", "true",
                       "'XCVbitmanip' (CORE-V Bit Manipulation)">;
def HasVendorXCVbitmanip
    : Predicate<"Subtarget->hasVendorXCVbitmanip()">,
      AssemblerPredicate<(all_of FeatureVendorXCVbitmanip),
                         "'XCVbitmanip' (CORE-V Bit Manipulation)">;

def FeatureVendorXCVmac
    : SubtargetFeature<"xcvmac", "HasVendorXCVmac", "true",
                       "'XCVmac' (CORE-V Multiply-Accumulate)">;
def HasVendorXCVmac
    : Predicate<"Subtarget->hasVendorXCVmac()">,
      AssemblerPredicate<(all_of FeatureVendorXCVmac),
                         "'XCVmac' (CORE-V Multiply-Accumulate)">;

def FeatureVendorXCVmem
    : SubtargetFeature<"xcvmem", "HasVendorXCVmem", "true",
                       "'XCVmem' (CORE-V Post-incrementing Load & Store)">;
def HasVendorXCVmem
    : Predicate<"Subtarget->hasVendorXCVmem()">,
      AssemblerPredicate<(any_of FeatureVendorXCVmem),
                         "'XCVmem' (CORE-V Post-incrementing Load & Store)">;

def FeatureVendorXCValu
    : SubtargetFeature<"xcvalu", "HasVendorXCValu", "true",
                       "'XCValu' (CORE-V ALU Operations)">;
def HasVendorXCValu
    : Predicate<"Subtarget->hasVendorXCValu()">,
      AssemblerPredicate<(all_of FeatureVendorXCValu),
                         "'XCValu' (CORE-V ALU Operations)">;

def FeatureVendorXCVsimd
    : SubtargetFeature<"xcvsimd", "HasVendorXCvsimd", "true",
                       "'XCVsimd' (CORE-V SIMD ALU)">;
def HasVendorXCVsimd
    : Predicate<"Subtarget->hasVendorXCVsimd()">,
      AssemblerPredicate<(any_of FeatureVendorXCVsimd),
                         "'XCVsimd' (CORE-V SIMD ALU)">;

def FeatureVendorXCVbi
    : SubtargetFeature<"xcvbi", "HasVendorXCVbi", "true",
                       "'XCVbi' (CORE-V Immediate Branching)">;
def HasVendorXCVbi
    : Predicate<"Subtarget->hasVendorXCVbi()">,
      AssemblerPredicate<(all_of FeatureVendorXCVbi),
                         "'XCVbi' (CORE-V Immediate Branching)">;

//===----------------------------------------------------------------------===//
// LLVM specific features and extensions
//===----------------------------------------------------------------------===//

// Feature32Bit exists to mark CPUs that support RV32 to distinquish them from
// tuning CPU names.
def Feature32Bit
    : SubtargetFeature<"32bit", "IsRV32", "true", "Implements RV32">;
def Feature64Bit
    : SubtargetFeature<"64bit", "IsRV64", "true", "Implements RV64">;
def IsRV64 : Predicate<"Subtarget->is64Bit()">,
             AssemblerPredicate<(all_of Feature64Bit),
                                "RV64I Base Instruction Set">;
def IsRV32 : Predicate<"!Subtarget->is64Bit()">,
             AssemblerPredicate<(all_of (not Feature64Bit)),
                                "RV32I Base Instruction Set">;

defvar RV32 = DefaultMode;
def RV64           : HwMode<"+64bit", [IsRV64]>;

def FeatureRVE
    : SubtargetFeature<"e", "IsRVE", "true",
                       "Implements RV{32,64}E (provides 16 rather than 32 GPRs)">;
def IsRVE : Predicate<"Subtarget->isRVE()">,
            AssemblerPredicate<(all_of FeatureRVE)>;

def FeatureRelax
    : SubtargetFeature<"relax", "EnableLinkerRelax", "true",
                       "Enable Linker relaxation.">;

foreach i = {1-31} in
  def FeatureReserveX#i :
      SubtargetFeature<"reserve-x"#i, "UserReservedRegister[RISCV::X"#i#"]",
                       "true", "Reserve X"#i>;

def FeatureSaveRestore : SubtargetFeature<"save-restore", "EnableSaveRestore",
                                          "true", "Enable save/restore.">;

def FeatureTrailingSeqCstFence : SubtargetFeature<"seq-cst-trailing-fence",
                                          "EnableSeqCstTrailingFence",
                                          "true",
                                          "Enable trailing fence for seq-cst store.">;

def FeatureFastUnalignedAccess
   : SubtargetFeature<"fast-unaligned-access", "HasFastUnalignedAccess",
                      "true", "Has reasonably performant unaligned "
                      "loads and stores (both scalar and vector)">;

def FeaturePostRAScheduler : SubtargetFeature<"use-postra-scheduler",
    "UsePostRAScheduler", "true", "Schedule again after register allocation">;

def TuneNoOptimizedZeroStrideLoad
   : SubtargetFeature<"no-optimized-zero-stride-load", "HasOptimizedZeroStrideLoad",
                      "false", "Hasn't optimized (perform fewer memory operations)"
                      "zero-stride vector load">;

def Experimental
   : SubtargetFeature<"experimental", "HasExperimental",
                      "true", "Experimental intrinsics">;

// Some vector hardware implementations do not process all VLEN bits in parallel
// and instead split over multiple cycles. DLEN refers to the datapath width
// that can be done in parallel.
def TuneDLenFactor2
   : SubtargetFeature<"dlen-factor-2", "DLenFactor2", "true",
                      "Vector unit DLEN(data path width) is half of VLEN">;

def TuneNoDefaultUnroll
    : SubtargetFeature<"no-default-unroll", "EnableDefaultUnroll", "false",
                       "Disable default unroll preference.">;

// SiFive 7 is able to fuse integer ALU operations with a preceding branch
// instruction.
def TuneShortForwardBranchOpt
    : SubtargetFeature<"short-forward-branch-opt", "HasShortForwardBranchOpt",
                       "true", "Enable short forward branch optimization">;
def HasShortForwardBranchOpt : Predicate<"Subtarget->hasShortForwardBranchOpt()">;
def NoShortForwardBranchOpt : Predicate<"!Subtarget->hasShortForwardBranchOpt()">;

def TuneConditionalCompressedMoveFusion
    : SubtargetFeature<"conditional-cmv-fusion", "HasConditionalCompressedMoveFusion",
                       "true", "Enable branch+c.mv fusion">;
def HasConditionalMoveFusion : Predicate<"Subtarget->hasConditionalMoveFusion()">;
def NoConditionalMoveFusion  : Predicate<"!Subtarget->hasConditionalMoveFusion()">;

def TuneSiFive7 : SubtargetFeature<"sifive7", "RISCVProcFamily", "SiFive7",
                                   "SiFive 7-Series processors",
                                   [TuneNoDefaultUnroll,
                                    TuneShortForwardBranchOpt]>;

def TuneVentanaVeyron : SubtargetFeature<"ventana-veyron", "RISCVProcFamily", "VentanaVeyron",
                                         "Ventana Veyron-Series processors">;

// Assume that lock-free native-width atomics are available, even if the target
// and operating system combination would not usually provide them. The user
// is responsible for providing any necessary __sync implementations. Code
// built with this feature is not ABI-compatible with code built without this
// feature, if atomic variables are exposed across the ABI boundary.
def FeatureForcedAtomics : SubtargetFeature<
    "forced-atomics", "HasForcedAtomics", "true",
    "Assume that lock-free native-width atomics are available">;
def HasAtomicLdSt
    : Predicate<"Subtarget->hasStdExtA() || Subtarget->hasForcedAtomics()">;

def FeatureTaggedGlobals : SubtargetFeature<"tagged-globals",
    "AllowTaggedGlobals",
    "true", "Use an instruction sequence for taking the address of a global "
    "that allows a memory tag in the upper address bits">;
