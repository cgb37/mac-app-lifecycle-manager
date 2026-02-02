#!/usr/bin/env bash
# test-log-rotation.sh - Test log rotation functionality
# Part of mac-app-lifecycle-manager test suite

set -euo pipefail

# =============================================================================
# SETUP
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Source common library
source "${REPO_ROOT}/scripts/lib/common.sh"

# Test directory
TEST_DIR="/tmp/mac-app-lifecycle-test-$$"
mkdir -p "${TEST_DIR}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

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

test_size_based_rotation() {
  test_start "Size-based rotation (15KB file with 10KB limit)"
  
  local test_log="${TEST_DIR}/size-test.log"
  
  # Create a 15KB log file
  dd if=/dev/zero bs=1024 count=15 2>/dev/null | tr '\0' 'x' > "${test_log}"
  local size_before
  size_before=$(ls -lh "${test_log}" | awk '{print $5}')
  echo "  Created log: ${size_before}"
  
  # Run rotation with 0.01 MB (10KB) limit
  rotate_log "${test_log}" 14 0.01
  
  # Verify rotation occurred
  if [[ -f "${test_log}.1.gz" ]]; then
    test_pass "Rotated to: ${test_log}.1.gz"
    local compressed_size
    compressed_size=$(ls -lh "${test_log}.1.gz" | awk '{print $5}')
    echo "  Compressed size: ${compressed_size}"
  else
    test_fail "No rotation file created"
  fi
  
  # Verify original log was truncated
  if [[ -f "${test_log}" ]] && [[ ! -s "${test_log}" ]]; then
    test_pass "Original log truncated to 0 bytes"
  else
    test_fail "Original log not properly truncated"
  fi
}

test_age_based_cleanup() {
  test_start "Age-based cleanup (delete logs older than 30 days)"
  
  local main_log="${TEST_DIR}/age-test.log"
  touch "${main_log}"
  
  # Create old rotated log (Jan 1, 2025)
  touch -t 202501010000 "${main_log}.1.gz"
  local old_date
  old_date=$(stat -f '%Sm' -t '%Y-%m-%d' "${main_log}.1.gz" 2>/dev/null || stat -c '%y' "${main_log}.1.gz" 2>/dev/null | cut -d' ' -f1)
  echo "  Old log created: ${main_log}.1.gz (${old_date})"
  
  # Create recent rotated log (today)
  touch "${main_log}.2.gz"
  local recent_date
  recent_date=$(stat -f '%Sm' -t '%Y-%m-%d' "${main_log}.2.gz" 2>/dev/null || stat -c '%y' "${main_log}.2.gz" 2>/dev/null | cut -d' ' -f1)
  echo "  Recent log created: ${main_log}.2.gz (${recent_date})"
  
  # Run cleanup with 30-day retention
  cleanup_old_logs "${TEST_DIR}" "age-test.log" 30
  
  # Verify old log deleted
  if [[ ! -f "${main_log}.1.gz" ]]; then
    test_pass "Old log deleted (older than 30 days)"
  else
    test_fail "Old log still exists"
  fi
  
  # Verify recent log preserved
  if [[ -f "${main_log}.2.gz" ]]; then
    test_pass "Recent log preserved (within 30 days)"
  else
    test_fail "Recent log incorrectly deleted"
  fi
}

test_multiple_rotations() {
  test_start "Multiple rotations (sequential rotation numbers)"
  
  local test_log="${TEST_DIR}/multi-test.log"
  
  # Create log and rotate 3 times
  for i in 1 2 3; do
    dd if=/dev/zero bs=1024 count=15 2>/dev/null | tr '\0' "$(printf '%d' $i)" > "${test_log}"
    rotate_log "${test_log}" 14 0.01
  done
  
  # Verify all rotation files exist with sequential numbers
  local all_exist=true
  for i in 1 2 3; do
    if [[ ! -f "${test_log}.${i}.gz" ]]; then
      all_exist=false
      break
    fi
  done
  
  if [[ "${all_exist}" == "true" ]]; then
    test_pass "Created 3 sequential rotation files"
    ls -lh "${TEST_DIR}"/multi-test.log.*.gz | awk '{print "  " $9 " (" $5 ")"}'
  else
    test_fail "Not all rotation files created"
  fi
}

test_rotate_logs_both() {
  test_start "Full rotate_logs (both main and error logs)"
  
  local main_log="${TEST_DIR}/full-main.log"
  local err_log="${TEST_DIR}/full-err.log"
  
  # Create oversized logs
  dd if=/dev/zero bs=1024 count=20 2>/dev/null | tr '\0' 'm' > "${main_log}"
  dd if=/dev/zero bs=1024 count=20 2>/dev/null | tr '\0' 'e' > "${err_log}"
  
  echo "  Created main log: $(ls -lh "${main_log}" | awk '{print $5}')"
  echo "  Created err log: $(ls -lh "${err_log}" | awk '{print $5}')"
  
  # Run rotation on both (10KB limit)
  rotate_logs "${main_log}" "${err_log}" 14 0.01
  
  # Verify both rotated
  local main_rotated=false
  local err_rotated=false
  
  [[ -f "${main_log}.1.gz" ]] && main_rotated=true
  [[ -f "${err_log}.1.gz" ]] && err_rotated=true
  
  if [[ "${main_rotated}" == "true" ]]; then
    test_pass "Main log rotated"
  else
    test_fail "Main log NOT rotated"
  fi
  
  if [[ "${err_rotated}" == "true" ]]; then
    test_pass "Error log rotated"
  else
    test_fail "Error log NOT rotated"
  fi
}

test_no_rotation_small_file() {
  test_start "No rotation for small files (below threshold)"
  
  local test_log="${TEST_DIR}/small-test.log"
  
  # Create a 5KB log file
  dd if=/dev/zero bs=1024 count=5 2>/dev/null | tr '\0' 's' > "${test_log}"
  echo "  Created log: $(ls -lh "${test_log}" | awk '{print $5}')"
  
  # Try to rotate with 10KB limit (should NOT rotate)
  rotate_log "${test_log}" 14 0.01
  
  # Verify no rotation occurred
  if [[ ! -f "${test_log}.1.gz" ]]; then
    test_pass "No rotation (file below size threshold)"
  else
    test_fail "File rotated when it should not have"
  fi
  
  # Verify original file unchanged
  if [[ -s "${test_log}" ]]; then
    test_pass "Original log preserved"
  else
    test_fail "Original log modified"
  fi
}

# =============================================================================
# RUN TESTS
# =============================================================================

echo ""
echo "======================================================"
echo "Log Rotation Test Suite"
echo "======================================================"
echo "Test directory: ${TEST_DIR}"

test_size_based_rotation
test_age_based_cleanup
test_multiple_rotations
test_rotate_logs_both
test_no_rotation_small_file

# =============================================================================
# CLEANUP & SUMMARY
# =============================================================================

echo ""
echo "======================================================"
echo "Cleaning up test directory..."
rm -rf "${TEST_DIR}"

echo ""
echo "======================================================"
echo "Test Summary"
echo "======================================================"
echo "Tests run:    ${TESTS_RUN}"
echo -e "Tests passed: ${GREEN}${TESTS_PASSED}${NC}"
if [[ ${TESTS_FAILED} -gt 0 ]]; then
  echo -e "Tests failed: ${RED}${TESTS_FAILED}${NC}"
else
  echo "Tests failed: 0"
fi
echo ""

if [[ ${TESTS_FAILED} -eq 0 ]]; then
  echo -e "${GREEN}✓ All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}✗ Some tests failed${NC}"
  exit 1
fi
