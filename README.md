# The LLVM Compiler Infrastructure

[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/llvm/llvm-project/badge)](https://securityscorecards.dev/viewer/?uri=github.com/llvm/llvm-project)
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/8273/badge)](https://www.bestpractices.dev/projects/8273)
[![libc++](https://github.com/llvm/llvm-project/actions/workflows/libcxx-build-and-test.yaml/badge.svg?branch=main&event=schedule)](https://github.com/llvm/llvm-project/actions/workflows/libcxx-build-and-test.yaml?query=event%3Aschedule)

Welcome to the LLVM project!

This repository contains the source code for LLVM, a toolkit for the
construction of highly optimized compilers, optimizers, and run-time
environments.

The LLVM project has multiple components. The core of the project is
itself called "LLVM". This contains all of the tools, libraries, and header
files needed to process intermediate representations and convert them into
object files. Tools include an assembler, disassembler, bitcode analyzer, and
bitcode optimizer.

C-like languages use the [Clang](https://clang.llvm.org/) frontend. This
component compiles C, C++, Objective-C, and Objective-C++ code into LLVM bitcode
-- and from there into object files, using LLVM.

Other components include:
the [libc++ C++ standard library](https://libcxx.llvm.org),
the [LLD linker](https://lld.llvm.org), and more.

## Getting the Source Code and Building LLVM

Consult the
[Getting Started with LLVM](https://llvm.org/docs/GettingStarted.html#getting-the-source-code-and-building-llvm)
page for information on building and running LLVM.

## 本地 RVT 工作区说明（非上游内容）

当前工作区将 `llvm-project` 与同级仓库 `llvm-compiler` 联动，用于 RVT 扩展开发与 Host-Device 联调验证。

路径约定（统一定义）：

- 工程根目录统一记为：`R_PROJECT_ROOT`
- WSL/Linux 示例：`export R_PROJECT_ROOT=/mnt/e/r-project`
- Windows 示例：`$env:R_PROJECT_ROOT='E:/r-project'`

后续命令示例均以 `${R_PROJECT_ROOT}` 为根目录，远程部署时只需替换该变量。

### RVT 扩展修改

本地集成时，会将 RVT 实现同步到本仓以下文件：

- `llvm/lib/Target/RISCV/RISCVInstrRVT.td`
- `llvm/lib/Target/RISCV/AsmParser/RISCVAsmParserRVT.cpp`
- `llvm/lib/Target/RISCV/AsmParser/CMakeLists.txt`（注册 parser 源文件）
- `llvm/lib/Target/RISCV/RISCVInstrInfo.td`（包含 RVT 指令定义入口）

同步脚本入口：

```bash
bash ${R_PROJECT_ROOT}/llvm-compiler/scripts/integrate-rvt-wsl.sh ${R_PROJECT_ROOT}/llvm-project
```

### 本地验证流程

1. 在 `llvm-build` 中构建 `llvm-mc`、`llc`。
2. 从 `llvm-compiler` 执行 MC 与 CodeGen 校验：

```bash
bash ${R_PROJECT_ROOT}/llvm-compiler/scripts/verify-rvt-mc-wsl.sh ${R_PROJECT_ROOT}/llvm-build
bash ${R_PROJECT_ROOT}/llvm-compiler/scripts/verify-rvt-codegen-wsl.sh ${R_PROJECT_ROOT}/llvm-build
```

3. 执行 Gate E 端到端检查：

```bash
bash ${R_PROJECT_ROOT}/llvm-compiler/scripts/run-gate-e-wsl.sh
SKIP_LAUNCH=0 AUTO_LAUNCH_BACKEND=1 NPU_RUNTIME_PRINTCHAR_STRICT=0 \
  bash ${R_PROJECT_ROOT}/llvm-compiler/scripts/run-gate-e-wsl.sh
```

模式说明：

- 本地 smoke 推荐 relaxed：`NPU_RUNTIME_PRINTCHAR_STRICT=0`
- CI 门禁推荐 strict：`NPU_RUNTIME_PRINTCHAR_STRICT=1`（通过 `run-gate-e-ci-wsl.sh`）

已知环境注意事项：

- 当 `/dev/shm` 容量不足时，E4 后端可能启动失败。
- 可执行以下命令扩容：

```bash
sudo mount -o remount,size=32G /dev/shm
```

状态快照（2026-03-18）：

- RVT 的 MC 与 CodeGen 冒烟在本地工作区可通过。
- Gate E 的 relaxed 主链路（E1/E2/E3/E4）可通过。
- strict 路径对 printchar 回读与共享内存约束更敏感，属于预期门禁行为。

For information on how to contribute to the LLVM project, please take a look at
the [Contributing to LLVM](https://llvm.org/docs/Contributing.html) guide.

## Getting in touch

Join the [LLVM Discourse forums](https://discourse.llvm.org/), [Discord
chat](https://discord.gg/xS7Z362),
[LLVM Office Hours](https://llvm.org/docs/GettingInvolved.html#office-hours) or
[Regular sync-ups](https://llvm.org/docs/GettingInvolved.html#online-sync-ups).

The LLVM project has adopted a [code of conduct](https://llvm.org/docs/CodeOfConduct.html) for
participants to all modes of communication within the project.
