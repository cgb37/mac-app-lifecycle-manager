#!/usr/bin/env bash
# test-cli-options.sh - Test CLI option handling
# Part of mac-app-lifecycle-manager test suite

set -euo pipefail

# =============================================================================
# SETUP
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# CLI script path
CLI_SCRIPT="${REPO_ROOT}/bin/mac-app-lifecycle"

# =============================================================================
# TEST HELPERS
# =============================================================================

test_start() {
  local test_name="$1"
  TESTS_RUN=$((TESTS_RUN + 1))
  echo ""
  echo "Test ${TESTS_RUN}: ${test_name}"
  echo "=================================================="
}

test_pass() {
  local message="$1"
  TESTS_PASSED=$((TESTS_PASSED + 1))
  echo -e "${GREEN}✓${NC} ${message}"
}

test_fail() {
  local message="$1"
  TESTS_FAILED=$((TESTS_FAILED + 1))
  echo -e "${RED}✗${NC} ${message}"
}

# =============================================================================
# TESTS
# =============================================================================

test_close_dry_run_option() {
  test_start "Close command --dry-run option"

  local output
  local exit_code
  output=$("$CLI_SCRIPT" close --dry-run 2>&1) || exit_code=$?

  # Should succeed when config exists
  if [[ ${exit_code:-0} -eq 0 ]]; then
    test_pass "Close --dry-run option parsed and executed correctly"
  else
    test_fail "Close --dry-run option failed unexpectedly (exit: ${exit_code:-0})"
    return 1
  fi

  if echo "$output" | grep -q "completed successfully"; then
    test_pass "Close --dry-run shows successful completion"
  else
    test_fail "Close --dry-run does not show successful completion"
    return 1
  fi
}

test_close_verbose_option() {
  test_start "Close command --verbose option"

  local output
  local exit_code
  output=$("$CLI_SCRIPT" close --verbose 2>&1) || exit_code=$?

  if [[ ${exit_code:-0} -eq 0 ]]; then
    test_pass "Close --verbose option parsed and executed correctly"
  else
    test_fail "Close --verbose option failed unexpectedly (exit: ${exit_code:-0})"
    return 1
  fi
}

test_open_dry_run_option() {
  test_start "Open command --dry-run option"

  local output
  local exit_code
  output=$("$CLI_SCRIPT" open --dry-run 2>&1) || exit_code=$?

  if [[ ${exit_code:-0} -eq 0 ]]; then
    test_pass "Open --dry-run option parsed and executed correctly"
  else
    test_fail "Open --dry-run option failed unexpectedly (exit: ${exit_code:-0})"
    return 1
  fi

  if echo "$output" | grep -q "completed successfully"; then
    test_pass "Open --dry-run shows successful completion"
  else
    test_fail "Open --dry-run does not show successful completion"
    return 1
  fi
}

test_open_verbose_option() {
  test_start "Open command --verbose option"

  local output
  local exit_code
  output=$("$CLI_SCRIPT" open --verbose 2>&1) || exit_code=$?

  if [[ ${exit_code:-0} -eq 0 ]]; then
    test_pass "Open --verbose option parsed and executed correctly"
  else
    test_fail "Open --verbose option failed unexpectedly (exit: ${exit_code:-0})"
    return 1
  fi
}

test_open_now_option() {
  test_start "Open command --now option"

  local output
  local exit_code
  output=$("$CLI_SCRIPT" open --now 2>&1) || exit_code=$?

  if [[ ${exit_code:-0} -eq 0 ]]; then
    test_pass "Open --now option parsed and executed correctly"
  else
    test_fail "Open --now option failed unexpectedly (exit: ${exit_code:-0})"
    return 1
  fi
}

test_close_unknown_option() {
  test_start "Close command unknown option error handling"

  local output
  local exit_code
  output=$("$CLI_SCRIPT" close --unknown 2>&1) || exit_code=$?

  if [[ ${exit_code:-0} -eq 1 ]]; then
    test_pass "Close unknown option returns exit code 1"
  else
    test_fail "Close unknown option should return exit code 1, got ${exit_code:-0}"
    return 1
  fi

  if echo "$output" | grep -q "Unknown option"; then
    test_pass "Close unknown option shows appropriate error message"
  else
    test_fail "Close unknown option does not show appropriate error message"
    return 1
  fi
}

test_open_unknown_option() {
  test_start "Open command unknown option error handling"

  local output
  local exit_code
  output=$("$CLI_SCRIPT" open --unknown 2>&1) || exit_code=$?

  if [[ ${exit_code:-0} -eq 1 ]]; then
    test_pass "Open unknown option returns exit code 1"
  else
    test_fail "Open unknown option should return exit code 1, got ${exit_code:-0}"
    return 1
  fi

  if echo "$output" | grep -q "Unknown option"; then
    test_pass "Open unknown option shows appropriate error message"
  else
    test_fail "Open unknown option does not show appropriate error message"
    return 1
  fi
}

test_multiple_options() {
  test_start "Multiple options handling"

  local output
  local exit_code
  output=$("$CLI_SCRIPT" open --now --dry-run --verbose 2>&1) || exit_code=$?

  if [[ ${exit_code:-0} -eq 0 ]]; then
    test_pass "Multiple options parsed and executed correctly"
  else
    test_fail "Multiple options failed unexpectedly (exit: ${exit_code:-0})"
    return 1
  fi
}

# =============================================================================
# MAIN
# =============================================================================

main() {
  echo -e "${YELLOW}=== Testing CLI Options ===${NC}\n"

  # Run all tests
  test_close_dry_run_option
  test_close_verbose_option
  test_open_dry_run_option
  test_open_verbose_option
  test_open_now_option
  test_close_unknown_option
  test_open_unknown_option
  test_multiple_options

  # Summary
  echo ""
  echo "=================================================="
  echo "Test Summary:"
  echo "  Total: $TESTS_RUN"
  echo -e "  Passed: ${GREEN}$TESTS_PASSED${NC}"
  echo -e "  Failed: ${RED}$TESTS_FAILED${NC}"

  if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "\n${GREEN}✓ All CLI option tests passed!${NC}"
    exit 0
  else
    echo -e "\n${RED}✗ $TESTS_FAILED CLI option tests failed${NC}"
    exit 1
  fi
}

main "$@"