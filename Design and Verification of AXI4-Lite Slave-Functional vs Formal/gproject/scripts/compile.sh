#!/bin/bash
# ----------------------------------------------------------------------
# VCS Compile Script for AXI4-Lite UVM VIP
# Synopsys VCS 2022
# ----------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Output directory
OUT_DIR="${SCRIPT_DIR}/../sim"
mkdir -p "$OUT_DIR"

echo "=================================================="
echo " VCS Compile: AXI4-Lite UVM VIP"
echo "=================================================="

vcs \
  -full64 \
  -sverilog \
  -ntb_opts uvm-1.2 \
  -timescale=1ns/1ps \
  -f filelist.f \
  -l "${OUT_DIR}/compile.log" \
  -o "${OUT_DIR}/simv" \
  -debug_access+all \
  +lint=TFIPC-L \
  -assert svaext \
  -cm line+fsm+tgl+branch+assert \
  -cm_hier "${SCRIPT_DIR}/cov_hier.cfg" \
  -cm_dir "${OUT_DIR}/coverage.vdb" \
  +define+UVM_NO_DEPRECATED \
  +define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR \
  -CFLAGS "-DVCS" \
  2>&1 | tee "${OUT_DIR}/compile_stdout.log"

echo ""
echo "Compile complete. Binary: ${OUT_DIR}/simv"
echo "Log: ${OUT_DIR}/compile.log"
