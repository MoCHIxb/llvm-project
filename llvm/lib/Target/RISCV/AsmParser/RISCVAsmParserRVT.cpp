//===----------------------------------------------------------------------===//
// RVT AsmParser direct implementation scaffold.
// Keep this file minimal and tablegen-first.
//===----------------------------------------------------------------------===//

#include "llvm/ADT/StringRef.h"

using namespace llvm;

namespace {

static unsigned getRVTDataTypeEncoding(StringRef TypeName) {
  if (TypeName == "fp16") return 0x00;
  if (TypeName == "bf16") return 0x01;
  if (TypeName == "fp32") return 0x02;
  if (TypeName == "e4m3") return 0x1C;
  if (TypeName == "e5m2") return 0x11;
  if (TypeName == "s32")  return 0x89;
  return 0;
}

static bool isRVTTransferKind(StringRef Kind) {
  return Kind == "u2u" || Kind == "u2d" || Kind == "d2u" || Kind == "d2d";
}

} // namespace

// Integration checklist:
// 1) Prefer TableGen-generated matcher path for tx.* mnemonics.
// 2) Use this file only for parser extensions that cannot be expressed in TableGen.
// 3) Keep dtype/transfer mapping consistent with spec/data/instruction_catalog.template.yaml.
