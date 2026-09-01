#!/bin/bash
# ----------------------------------------------------------------------
# VCS Run Script for AXI4-Lite UVM VIP
# Synopsys VCS 2022
# ----------------------------------------------------------------------
# Usage:
#   ./run.sh                                # runs axi4lite_full_coverage_test
#   ./run.sh axi4lite_write_test            # runs specific test
#   ./run.sh axi4lite_random_test +seed     # random seed
#   ./run.sh all                            # runs all tests sequentially
# ----------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SIM_DIR="${SCRIPT_DIR}/../sim"
SIMV="${SIM_DIR}/simv"

if [ ! -f "$SIMV" ]; then
  echo "ERROR: simv not found. Run compile.sh first."
  exit 1
fi

# ----------------------------------------------------------------------
# Test list
# ----------------------------------------------------------------------
ALL_TESTS=(
  axi4lite_write_test
  axi4lite_read_test
  axi4lite_b2b_test
  axi4lite_strobe_test
  axi4lite_prot_test
  axi4lite_delay_test
  axi4lite_data_pattern_test
  axi4lite_random_test
  axi4lite_reset_test
  axi4lite_rand_delay_test
  axi4lite_full_coverage_test
)

TEST_NAME="${1:-axi4lite_full_coverage_test}"
SEED="${2:-$RANDOM}"

run_single_test() {
  local tname="$1"
  local tseed="$2"
  local run_dir="${SIM_DIR}/run_${tname}"

  mkdir -p "$run_dir"

  echo "=================================================="
  echo " Running: ${tname} (seed=${tseed})"
  echo "=================================================="

  cd "$run_dir"

  "${SIMV}" \
    +UVM_TESTNAME="${tname}" \
    +UVM_VERBOSITY=UVM_MEDIUM \
    +ntb_random_seed="${tseed}" \
    -cm line+fsm+tgl+branch+assert \
    -cm_hier "${SCRIPT_DIR}/cov_hier.cfg" \
    -cm_dir "${SIM_DIR}/coverage.vdb" \
    -cm_name "${tname}" \
    -l "${tname}.log" \
    +dump_vpd \
    2>&1 | tee "${tname}_stdout.log"

  echo ""
  echo "Log: ${run_dir}/${tname}.log"
  echo ""

  # Check pass/fail
  if grep -q "TEST PASSED" "${tname}.log"; then
    echo ">>> ${tname}: PASSED <<<"
    return 0
  else
    echo ">>> ${tname}: FAILED <<<"
    return 1
  fi
}

# ----------------------------------------------------------------------
# Run
# ----------------------------------------------------------------------
if [ "$TEST_NAME" = "all" ]; then
  PASS=0
  FAIL=0
  FAILED_TESTS=""

  for t in "${ALL_TESTS[@]}"; do
    if run_single_test "$t" "$SEED"; then
      PASS=$((PASS + 1))
    else
      FAIL=$((FAIL + 1))
      FAILED_TESTS="${FAILED_TESTS} ${t}"
    fi
  done

  echo ""
  echo "=================================================="
  echo " Regression Summary"
  echo "=================================================="
  echo "  Total : ${#ALL_TESTS[@]}"
  echo "  Passed: ${PASS}"
  echo "  Failed: ${FAIL}"
  if [ $FAIL -gt 0 ]; then
    echo "  Failed tests:${FAILED_TESTS}"
  fi
  echo ""

  # Generate merged coverage report
  echo "Generating coverage report..."
  urg -dir "${SIM_DIR}/coverage.vdb" -report "${SIM_DIR}/coverage_report" -format both 2>/dev/null || true
  echo "Coverage report: ${SIM_DIR}/coverage_report/"

  exit $FAIL
else
  run_single_test "$TEST_NAME" "$SEED"
fi
