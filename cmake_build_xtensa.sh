#!/bin/bash
# cmake_build_xtensa.sh — Configure and build llama-simple for Xtensa HiFi5s bare-metal
# Run from /home/bhanup/__work_gguf/llama.cpp-hifi/
# Usage: bash cmake_build_xtensa.sh [hifi5s_ao_7_2GSram_L2_1M | hifi5s_ao_7_2GSram_L2_Def]

CORE="${1:-hifi5s_ao_7_2GSram_L2_1M}"
CONFIGS_BASE="/home/mikhilg/projects/user/bhanup/RJ-2025.5-linux"
XTENSA_TOOLS_BIN="/fac/ai_regress2/xtensa_new/XtDevTools/install/tools/RJ-2025.5-linux/XtensaTools/bin"

export XTENSA_SYSTEM="${CONFIGS_BASE}/${CORE}/config"
export XTENSA_CORE="${CORE}"
export PATH="${XTENSA_TOOLS_BIN}:${PATH}"

# Verify cmake is available
CMAKE_BIN=$(which cmake 2>/dev/null)
if [ -z "${CMAKE_BIN}" ]; then
    echo "ERROR: cmake not found in PATH."
    echo "Add cmake to PATH before running this script."
    exit 1
fi
echo "Using cmake: ${CMAKE_BIN}"
echo "Using XTENSA_CORE: ${XTENSA_CORE}"
echo "Using XTENSA_SYSTEM: ${XTENSA_SYSTEM}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

# Clean previous build (re-configure ensures CMAKE_COMMAND uses the cmake found above)
rm -rf build_xtensa

cmake -DCMAKE_TOOLCHAIN_FILE=cmake/xtensa-hifi5s-toolchain.cmake \
      -DCMAKE_BUILD_TYPE=Release \
      -DBARE_METAL_TEST=ON \
      -DLLAMA_BUILD_TESTS=OFF \
      -DLLAMA_BUILD_EXAMPLES=ON \
      -B build_xtensa \
      2>&1 | tee _log_build_cmake_setup

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "cmake configure FAILED — see _log_build_cmake_setup"
    exit 1
fi

# Use -j2 (not -j$(nproc)) — NFS filesystems can stale-handle under heavy parallel writes.
# ggml.c alone generates 50K+ asm lines; many parallel large files can saturate NFS.
cmake --build build_xtensa --target llama-simple -j2 \
      2>&1 | tee _log_build_cmake

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "cmake build FAILED — see _log_build_cmake"
    exit 1
fi

echo ""
echo "Build successful: build_xtensa/bin/llama-simple"
echo "Run: xt-run --memlimit=4096 --turbo build_xtensa/bin/llama-simple -n 16 -m <model.gguf> \"Once upon a time\""
