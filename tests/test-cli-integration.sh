#!/usr/bin/env bash
# test-cli-integration.sh - Test CLI integration with shell wrappers
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

# Paths
CLI_SCRIPT="${REPO_ROOT}/bin/mac-app-lifecycle"
CLOSE_SCRIPT="${REPO_ROOT}/scripts/close-apps/close-apps.sh"
OPEN_SCRIPT="${REPO_ROOT}/scripts/open-apps/open-apps.sh"
CLOSE_CONFIG="${REPO_ROOT}/config/close-apps.conf"
OPEN_CONFIG="${REPO_ROOT}/config/open-apps.conf"

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

test_close_config_validation() {
  test_start "Close command config validation"

  # Remove config temporarily if it exists
  local config_backup=""
  if [[ -f "$CLOSE_CONFIG" ]]; then
    config_backup="${CLOSE_CONFIG}.backup"
    mv "$CLOSE_CONFIG" "$config_backup"
  fi

  # Test without config
  local output
  local exit_code
  output=$("$CLI_SCRIPT" close --dry-run 2>&1) || exit_code=$?

  # Restore config
  if [[ -n "$config_backup" ]]; then
    mv "$config_backup" "$CLOSE_CONFIG"
  fi

  if [[ ${exit_code:-0} -eq 3 ]]; then
    test_pass "Close command properly validates config file existence"
  else
    test_fail "Close command should fail with exit code 3 when config missing, got ${exit_code:-0}"
    return 1
  fi

  if echo "$output" | grep -q "Close-apps config not found"; then
    test_pass "Close command shows appropriate config error message"
  else
    test_fail "Close command does not show appropriate config error message"
    return 1
  fi
}

test_open_config_validation() {
  test_start "Open command config validation"

  # Remove config temporarily if it exists
  local config_backup=""
  if [[ -f "$OPEN_CONFIG" ]]; then
    config_backup="${OPEN_CONFIG}.backup"
    mv "$OPEN_CONFIG" "$config_backup"
  fi

  # Test without config
  local output
  local exit_code
  output=$("$CLI_SCRIPT" open --dry-run 2>&1) || exit_code=$?

  # Restore config
  if [[ -n "$config_backup" ]]; then
    mv "$config_backup" "$OPEN_CONFIG"
  fi

  if [[ ${exit_code:-0} -eq 3 ]]; then
    test_pass "Open command properly validates config file existence"
  else
    test_fail "Open command should fail with exit code 3 when config missing, got ${exit_code:-0}"
    return 1
  fi

  if echo "$output" | grep -q "Open-apps config not found"; then
    test_pass "Open command shows appropriate config error message"
  else
    test_fail "Open command does not show appropriate config error message"
    return 1
  fi
}

test_close_dry_run_integration() {
  test_start "Close command dry-run integration"

  # Ensure config exists for this test
  if [[ ! -f "$CLOSE_CONFIG" ]]; then
    test_fail "Close config file missing - cannot test integration"
    return 1
  fi

  local output
  if output=$("$CLI_SCRIPT" close --dry-run 2>&1); then
    if echo "$output" | grep -q "Executing close-apps script"; then
      test_pass "Close command calls shell wrapper script"
    else
      test_fail "Close command does not show execution message"
      return 1
    fi

    if echo "$output" | grep -q "completed successfully"; then
      test_pass "Close command reports successful completion"
    else
      test_fail "Close command does not report successful completion"
      return 1
    fi
  else
    test_fail "Close dry-run command failed to execute"
    return 1
  fi
}

test_open_dry_run_integration() {
  test_start "Open command dry-run integration"

  # Ensure config exists for this test
  if [[ ! -f "$OPEN_CONFIG" ]]; then
    test_fail "Open config file missing - cannot test integration"
    return 1
  fi

  local output
  if output=$("$CLI_SCRIPT" open --dry-run 2>&1); then
    if echo "$output" | grep -q "Executing open-apps script"; then
      test_pass "Open command calls shell wrapper script"
    else
      test_fail "Open command does not show execution message"
      return 1
    fi

    if echo "$output" | grep -q "completed successfully"; then
      test_pass "Open command reports successful completion"
    else
      test_fail "Open command does not report successful completion"
      return 1
    fi
  else
    test_fail "Open dry-run command failed to execute"
    return 1
  fi
}

test_close_verbose_integration() {
  test_start "Close command verbose integration"

  # Ensure config exists for this test
  if [[ ! -f "$CLOSE_CONFIG" ]]; then
    test_fail "Close config file missing - cannot test integration"
    return 1
  fi

  local output
  if output=$("$CLI_SCRIPT" close --verbose --dry-run 2>&1); then
    test_pass "Close verbose command executes successfully"
  else
    test_fail "Close verbose command failed to execute"
    return 1
  fi
}

test_open_verbose_integration() {
  test_start "Open command verbose integration"

  # Ensure config exists for this test
  if [[ ! -f "$OPEN_CONFIG" ]]; then
    test_fail "Open config file missing - cannot test integration"
    return 1
  fi

  local output
  if output=$("$CLI_SCRIPT" open --verbose --dry-run 2>&1); then
    test_pass "Open verbose command executes successfully"
  else
    test_fail "Open verbose command failed to execute"
    return 1
  fi
}

test_installation_validation() {
  test_start "Installation validation integration"

  # Test with missing scripts directory
  local scripts_backup=""
  if [[ -d "${REPO_ROOT}/scripts" ]]; then
    scripts_backup="${REPO_ROOT}/scripts.backup"
    mv "${REPO_ROOT}/scripts" "$scripts_backup"
  fi

  local output
  local exit_code
  output=$("$CLI_SCRIPT" close --dry-run 2>&1) || exit_code=$?

  # Restore scripts directory
  if [[ -n "$scripts_backup" ]]; then
    mv "$scripts_backup" "${REPO_ROOT}/scripts"
  fi

  if [[ ${exit_code:-0} -eq 2 ]]; then
    test_pass "CLI properly validates installation (scripts directory)"
  else
    test_fail "CLI should fail with exit code 2 when scripts missing, got ${exit_code:-0}"
    return 1
  fi
}

# =============================================================================
# MAIN
# =============================================================================

main() {
  echo -e "${YELLOW}=== Testing CLI Integration ===${NC}\n"

  # Run all tests
  test_close_config_validation
  test_open_config_validation
  test_close_dry_run_integration
  test_open_dry_run_integration
  test_close_verbose_integration
  test_open_verbose_integration
  test_installation_validation

  # Summary
  echo ""
  echo "=================================================="
  echo "Test Summary:"
  echo "  Total: $TESTS_RUN"
  echo -e "  Passed: ${GREEN}$TESTS_PASSED${NC}"
  echo -e "  Failed: ${RED}$TESTS_FAILED${NC}"

  if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "\n${GREEN}✓ All CLI integration tests passed!${NC}"
    exit 0
  else
    echo -e "\n${RED}✗ $TESTS_FAILED CLI integration tests failed${NC}"
    exit 1
  fi
}

main "$@"