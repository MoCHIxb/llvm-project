//===----------------------------------------------------------------------===//
// RVT instruction definitions for direct in-repo implementation.
// Compile-first minimal baseline: 32-bit families are encoded, macro family is
// represented by pseudo placeholders in this phase.
//===----------------------------------------------------------------------===//

// Custom opcode from current RVT 32-bit proposal.
def OPC_RVT32 : RISCVOpcode<"OPC_RVT32", 0b0001011>;
def OPC_RVT64 : RISCVOpcode<"OPC_RVT64", 0b0111111>;

// Local immediate operand for Base tcsr address field.
def rvt_uimm10 : RISCVUImmLeafOp<10>;

// Feature gates.
def FeatureTXBase  : SubtargetFeature<"txbase", "HasTXBase", "true", "Enable RVT base instructions">;
def FeatureTXLSU   : SubtargetFeature<"txlsu",  "HasTXLSU",  "true", "Enable RVT LSU instructions">;
def FeatureTXMat   : SubtargetFeature<"txmat",  "HasTXMat",  "true", "Enable RVT MAT instructions">;
def FeatureTXMacro : SubtargetFeature<"txmacro","HasTXMacro","true", "Enable RVT MACRO instructions">;

// Spec-aligned aliases. Keep both tx* and ztx* accepted in -mattr.
def FeatureZTXBase  : SubtargetFeature<"ztxbase", "HasZTXBase", "true", "Enable RVT base instructions (spec alias)">;
def FeatureZTXLSU   : SubtargetFeature<"ztxlsu",  "HasZTXLSU",  "true", "Enable RVT LSU instructions (spec alias)">;
def FeatureZTXMat   : SubtargetFeature<"ztxmat",  "HasZTXMat",  "true", "Enable RVT MAT instructions (spec alias)">;
def FeatureZTXMacro : SubtargetFeature<"ztxmacro","HasZTXMacro","true", "Enable RVT MACRO instructions (spec alias)">;

// -------------------------------
// 32-bit families (base/lsu/mat)
// -------------------------------

class RVTBaseTCSRRead<string asmstr>
  : RVInst<(outs GPR:$rd), (ins uimm4:$unit, rvt_uimm10:$tcsr_addr),
           asmstr, "", [], InstFormatOther> {
  bits<5> rd;
  bits<4> unit;
  bits<10> tcsr_addr;
  let hasSideEffects = 1;
  let mayLoad = 0;
  let mayStore = 0;
  let Inst{31-27} = 0b00000;
  let Inst{26-23} = unit;
  let Inst{22-13} = tcsr_addr;
  let Inst{12} = 0b1;
  let Inst{11-7} = rd;
  let Inst{6-0} = OPC_RVT32.Value;
}

class RVTBaseTCSRWrite<string asmstr>
  : RVInst<(outs), (ins GPR:$src, uimm4:$unit, rvt_uimm10:$tcsr_addr),
           asmstr, "", [], InstFormatOther> {
  bits<5> src;
  bits<4> unit;
  bits<10> tcsr_addr;
  let hasSideEffects = 1;
  let mayLoad = 0;
  let mayStore = 0;
  let Inst{31-27} = 0b00000;
  let Inst{26-23} = unit;
  let Inst{22-13} = tcsr_addr;
  let Inst{12} = 0b0;
  let Inst{11-7} = src;
  let Inst{6-0} = OPC_RVT32.Value;
}

class RVTDMABase<bits<1> src_v, bits<1> dst_v, string asmstr>
  : RVInst<(outs GPR:$rd), (ins GPR:$rs1, uimm3:$group),
           asmstr, "", [], InstFormatOther> {
  bits<5> rd;
  bits<5> rs1;
  bits<3> group;
  let hasSideEffects = 1;
  let mayLoad = 0;
  let mayStore = 0;
  let Inst{31-25} = 0b0000100;
  let Inst{24-23} = 0b00;
  let Inst{22-20} = group;
  let Inst{19-15} = rs1;
  let Inst{14} = 0b0;
  let Inst{13} = src_v;
  let Inst{12} = dst_v;
  let Inst{11-7} = rd;
  let Inst{6-0} = OPC_RVT32.Value;
}

class RVTMAT<bits<1> acc_v, string asmstr>
  : RVInst<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm3:$group),
           asmstr, "", [], InstFormatOther> {
  bits<5> rd;
  bits<5> rs1;
  bits<5> rs2;
  bits<3> group;
  let hasSideEffects = 1;
  let mayLoad = 0;
  let mayStore = 0;
  let Inst{31-29} = 0b001;
  let Inst{28} = 0b0;
  let Inst{27-25} = group;
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-13} = 0b00;
  let Inst{12} = acc_v;
  let Inst{11-7} = rd;
  let Inst{6-0} = OPC_RVT32.Value;
}

class RVTMATSetPtr<string asmstr>
  : RVInst<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm3:$group),
           asmstr, "", [], InstFormatOther> {
  bits<5> rd;
  bits<5> rs1;
  bits<5> rs2;
  bits<3> group;
  let hasSideEffects = 1;
  let mayLoad = 0;
  let mayStore = 0;
  let Inst{31-29} = 0b001;
  let Inst{28} = 0b0;
  let Inst{27-25} = group;
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = 0b010;
  let Inst{11-7} = rd;
  let Inst{6-0} = OPC_RVT32.Value;
}

class RVTMacroElemwise<bits<6> op_v, bits<8> dtype_v, string asmstr>
  : RVInst64<(outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2, uimm3:$group),
             asmstr, "", [], InstFormatOther> {
  bits<5> rd;
  bits<5> rs1;
  bits<5> rs2;
  bits<3> group;
  let hasSideEffects = 1;
  let mayLoad = 1;
  let mayStore = 1;
  let Inst{63-47} = 0;
  let Inst{46} = 0;
  let Inst{45-40} = op_v;
  let Inst{39-32} = dtype_v;
  let Inst{31-25} = 0b0000000;
  let Inst{24-20} = rs2;
  let Inst{19-15} = rs1;
  let Inst{14-12} = group;
  let Inst{11-7} = rd;
  let Inst{6-0} = OPC_RVT64.Value;
}

// -------------------------------
// Phase-1 instruction definitions
// -------------------------------

// Base/TCSR.
def RVT_BASE_TCSR_READ  : RVTBaseTCSRRead<"tx.base.tcsr.read $rd, $unit, $tcsr_addr">;
def RVT_BASE_TCSR_WRITE : RVTBaseTCSRWrite<"tx.base.tcsr.write $src, $unit, $tcsr_addr">;

// LSU DMA.
def RVT_LSU_DMA_U2U : RVTDMABase<0, 0, "tx.lsu.dma.u2u $rd, $rs1, $group">;
def RVT_LSU_DMA_U2D : RVTDMABase<0, 1, "tx.lsu.dma.u2d $rd, $rs1, $group">;
def RVT_LSU_DMA_D2U : RVTDMABase<1, 0, "tx.lsu.dma.d2u $rd, $rs1, $group">;
def RVT_LSU_DMA_D2D : RVTDMABase<1, 1, "tx.lsu.dma.d2d $rd, $rs1, $group">;

// MAT.
def RVT_MAT_MM     : RVTMAT<0, "tx.mat.mm $rd, $rs1, $rs2, $group">;
def RVT_MAT_MMA    : RVTMAT<1, "tx.mat.mma $rd, $rs1, $rs2, $group">;
def RVT_MAT_SETPTR : RVTMATSetPtr<"tx.mat.setptr $rd, $rs1, $rs2, $group">;

// Macro.
let hasSideEffects = 1, mayLoad = 0, mayStore = 0 in {
def RVT_MACRO_ELEMWISE_ADD_S32 : RVTMacroElemwise<0b000000, 0x02,
  "tx.macro.elemwise.add.s32 $rd, $rs1, $rs2, $group">;
def RVT_MACRO_CONVERT_S32_F32  : Pseudo<(outs GPR:$rd), (ins GPR:$rs1), []>;
def RVT_MACRO_SFU_EXP          : Pseudo<(outs GPR:$rd), (ins GPR:$rs1), []>;
def RVT_MACRO_REDUCE_ADD_S32   : Pseudo<(outs GPR:$rd), (ins GPR:$rs1), []>;
}
