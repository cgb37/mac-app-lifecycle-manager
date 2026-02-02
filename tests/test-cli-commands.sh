#!/usr/bin/env bash
# test-cli-commands.sh - Test CLI command parsing and basic functionality
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

test_cli_exists() {
  test_start "CLI script exists and is executable"

  if [[ -f "$CLI_SCRIPT" ]]; then
    test_pass "CLI script found: $CLI_SCRIPT"
  else
    test_fail "CLI script not found: $CLI_SCRIPT"
    return 1
  fi

  if [[ -x "$CLI_SCRIPT" ]]; then
    test_pass "CLI script is executable"
  else
    test_fail "CLI script is not executable"
    return 1
  fi
}

test_cli_syntax() {
  test_start "CLI script syntax validation"

  if bash -n "$CLI_SCRIPT"; then
    test_pass "CLI script syntax is valid"
  else
    test_fail "CLI script has syntax errors"
    return 1
  fi
}

test_help_command() {
  test_start "Help command functionality"

  local output
  if output=$("$CLI_SCRIPT" help 2>&1); then
    if echo "$output" | grep -q "USAGE:"; then
      test_pass "Help command shows usage information"
    else
      test_fail "Help command does not show usage information"
      return 1
    fi
  else
    test_fail "Help command failed to execute"
    return 1
  fi
}

test_version_command() {
  test_start "Version command functionality"

  local output
  if output=$("$CLI_SCRIPT" --version 2>&1); then
    if echo "$output" | grep -q "mac-app-lifecycle version"; then
      test_pass "Version command shows version information"
    else
      test_fail "Version command does not show version information"
      return 1
    fi
  else
    test_fail "Version command failed to execute"
    return 1
  fi
}

test_unknown_command() {
  test_start "Unknown command error handling"

  local output
  local exit_code
  output=$("$CLI_SCRIPT" nonexistent 2>&1) || exit_code=$?

  if [[ ${exit_code:-0} -eq 1 ]]; then
    test_pass "Unknown command returns exit code 1"
  else
    test_fail "Unknown command should return exit code 1, got ${exit_code:-0}"
    return 1
  fi

  if echo "$output" | grep -q "Unknown command"; then
    test_pass "Unknown command shows appropriate error message"
  else
    test_fail "Unknown command does not show appropriate error message"
    return 1
  fi
}

test_no_command() {
  test_start "No command specified error handling"

  local output
  local exit_code
  output=$("$CLI_SCRIPT" 2>&1) || exit_code=$?

  if [[ ${exit_code:-0} -eq 1 ]]; then
    test_pass "No command returns exit code 1"
  else
    test_fail "No command should return exit code 1, got ${exit_code:-0}"
    return 1
  fi

  if echo "$output" | grep -q "No command specified"; then
    test_pass "No command shows appropriate error message"
  else
    test_fail "No command does not show appropriate error message"
    return 1
  fi
}

test_status_command_stub() {
  test_start "Status command functionality"

  local output
  if output=$("$CLI_SCRIPT" status 2>&1); then
    if echo "$output" | grep -q "mac-app-lifecycle Status"; then
      test_pass "Status command shows status header"
    else
      test_fail "Status command does not show status header"
      return 1
    fi

    if echo "$output" | grep -q "Close Apps Agent:"; then
      test_pass "Status command shows close apps agent info"
    else
      test_fail "Status command does not show close apps agent info"
      return 1
    fi

    if echo "$output" | grep -q "Open Apps Agent:"; then
      test_pass "Status command shows open apps agent info"
    else
      test_fail "Status command does not show open apps agent info"
      return 1
    fi
  else
    test_fail "Status command failed to execute"
    return 1
  fi
}

test_logs_command_stub() {
  test_start "Logs command functionality"

  # Test logs command without subcommand (should show error)
  local output
  local exit_code
  output=$("$CLI_SCRIPT" logs 2>&1) || exit_code=$?

  if [[ ${exit_code:-0} -eq 1 ]]; then
    test_pass "Logs command without subcommand returns exit code 1"
  else
    test_fail "Logs command without subcommand should return exit code 1, got ${exit_code:-0}"
    return 1
  fi

  if echo "$output" | grep -q "Please specify 'close' or 'open' logs"; then
    test_pass "Logs command shows appropriate error message for missing subcommand"
  else
    test_fail "Logs command does not show appropriate error message for missing subcommand"
    return 1
  fi

  # Test logs close command
  if output=$("$CLI_SCRIPT" logs close 2>&1); then
    if echo "$output" | grep -q "Close Apps Logs"; then
      test_pass "Logs close command shows header"
    else
      test_fail "Logs close command does not show expected header"
      return 1
    fi
  else
    test_fail "Logs close command failed to execute"
    return 1
  fi

  # Test logs open command
  if output=$("$CLI_SCRIPT" logs open 2>&1); then
    if echo "$output" | grep -q "Open Apps Logs"; then
      test_pass "Logs open command shows header"
    else
      test_fail "Logs open command does not show expected header"
      return 1
    fi
  else
    test_fail "Logs open command failed to execute"
    return 1
  fi
}

test_plist_command_stub() {
  test_start "Plist command functionality"

  # Test plist command without subcommand (should show error)
  local output
  local exit_code
  output=$("$CLI_SCRIPT" plist 2>&1) || exit_code=$?

  if [[ ${exit_code:-0} -eq 1 ]]; then
    test_pass "Plist command without subcommand returns exit code 1"
  else
    test_fail "Plist command without subcommand should return exit code 1, got ${exit_code:-0}"
    return 1
  fi

  if echo "$output" | grep -q "Please specify 'close' or 'open' plist"; then
    test_pass "Plist command shows appropriate error message for missing subcommand"
  else
    test_fail "Plist command does not show appropriate error message for missing subcommand"
    return 1
  fi

  # Test plist close command
  if output=$("$CLI_SCRIPT" plist close 2>&1); then
    if echo "$output" | grep -q "Close Apps Plist Configuration"; then
      test_pass "Plist close command shows header"
    else
      test_fail "Plist close command does not show expected header"
      return 1
    fi
  else
    test_fail "Plist close command failed to execute"
    return 1
  fi

  # Test plist open command
  if output=$("$CLI_SCRIPT" plist open 2>&1); then
    if echo "$output" | grep -q "Open Apps Plist Configuration"; then
      test_pass "Plist open command shows header"
    else
      test_fail "Plist open command does not show expected header"
      return 1
    fi
  else
    test_fail "Plist open command failed to execute"
    return 1
  fi
}

# =============================================================================
# MAIN
# =============================================================================

main() {
  echo -e "${YELLOW}=== Testing CLI Commands ===${NC}\n"

  # Run all tests
  test_cli_exists
  test_cli_syntax
  test_help_command
  test_version_command
  test_unknown_command
  test_no_command
  test_status_command_stub
  test_logs_command_stub
  test_plist_command_stub

  # Summary
  echo ""
  echo "=================================================="
  echo "Test Summary:"
  echo "  Total: $TESTS_RUN"
  echo -e "  Passed: ${GREEN}$TESTS_PASSED${NC}"
  echo -e "  Failed: ${RED}$TESTS_FAILED${NC}"

  if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "\n${GREEN}✓ All CLI command tests passed!${NC}"
    exit 0
  else
    echo -e "\n${RED}✗ $TESTS_FAILED CLI command tests failed${NC}"
    exit 1
  fi
}

main "$@"