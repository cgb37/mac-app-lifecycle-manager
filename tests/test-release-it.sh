#!/usr/bin/env bash
#
# Test script for release-it configuration and workflow
# Tests dry-run mode to validate release process without making changes
#
# Usage: ./tests/test-release-it.sh

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo -e "${BLUE}=== Testing release-it configuration ===${NC}\n"

# Helper functions
test_passed() {
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓ PASS:${NC} $1"
}

test_failed() {
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗ FAIL:${NC} $1"
}

# Change to project root
cd "${PROJECT_ROOT}"

# Test 1: Check if package.json exists
echo -e "${YELLOW}Test 1:${NC} Checking package.json exists..."
if [ -f "package.json" ]; then
    test_passed "package.json found"
else
    test_failed "package.json not found"
fi

# Test 2: Check if .release-it.json exists
echo -e "${YELLOW}Test 2:${NC} Checking .release-it.json exists..."
if [ -f ".release-it.json" ]; then
    test_passed ".release-it.json found"
else
    test_failed ".release-it.json not found"
fi

# Test 3: Check if release-it is installed
echo -e "${YELLOW}Test 3:${NC} Checking if release-it is installed..."
if [ -d "node_modules" ] && [ -d "node_modules/release-it" ]; then
    test_passed "release-it is installed"
elif command -v npm &> /dev/null; then
    echo -e "${YELLOW}  Installing dependencies...${NC}"
    npm install --silent
    if [ -d "node_modules/release-it" ]; then
        test_passed "release-it installed successfully"
    else
        test_failed "Failed to install release-it"
    fi
else
    test_failed "npm not found - cannot install release-it"
fi

# Test 4: Check if conventional-changelog plugin is installed
echo -e "${YELLOW}Test 4:${NC} Checking if conventional-changelog plugin is installed..."
if [ -d "node_modules/@release-it/conventional-changelog" ]; then
    test_passed "conventional-changelog plugin is installed"
else
    test_failed "conventional-changelog plugin not found"
fi

# Test 5: Validate package.json has correct scripts
echo -e "${YELLOW}Test 5:${NC} Validating package.json scripts..."
if grep -q '"release":' package.json && \
   grep -q '"release:major":' package.json && \
   grep -q '"release:minor":' package.json && \
   grep -q '"release:patch":' package.json; then
    test_passed "All release scripts defined in package.json"
else
    test_failed "Missing release scripts in package.json"
fi

# Test 6: Check if release.sh is executable
echo -e "${YELLOW}Test 6:${NC} Checking if release.sh is executable..."
if [ -f "scripts/release.sh" ]; then
    if [ -x "scripts/release.sh" ]; then
        test_passed "scripts/release.sh is executable"
    else
        echo -e "${YELLOW}  Making scripts/release.sh executable...${NC}"
        chmod +x scripts/release.sh
        test_passed "scripts/release.sh made executable"
    fi
else
    test_failed "scripts/release.sh not found"
fi

# Test 7: Check if update-version.sh exists and is executable
echo -e "${YELLOW}Test 7:${NC} Checking if update-version.sh is executable..."
if [ -f "scripts/update-version.sh" ]; then
    if [ -x "scripts/update-version.sh" ]; then
        test_passed "scripts/update-version.sh is executable"
    else
        echo -e "${YELLOW}  Making scripts/update-version.sh executable...${NC}"
        chmod +x scripts/update-version.sh
        test_passed "scripts/update-version.sh made executable"
    fi
else
    test_failed "scripts/update-version.sh not found"
fi

# Test 8: Validate .release-it.json configuration
echo -e "${YELLOW}Test 8:${NC} Validating .release-it.json configuration..."
if command -v jq &> /dev/null; then
    if jq empty .release-it.json 2>/dev/null; then
        test_passed ".release-it.json is valid JSON"
    else
        test_failed ".release-it.json contains invalid JSON"
    fi
else
    echo -e "${YELLOW}  Skipping JSON validation (jq not installed)${NC}"
fi

# Test 9: Check git configuration
echo -e "${YELLOW}Test 9:${NC} Checking git repository configuration..."
if git rev-parse --git-dir > /dev/null 2>&1; then
    test_passed "Git repository initialized"
    
    # Check if on main branch
    current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    if [ "$current_branch" = "main" ]; then
        test_passed "Currently on main branch"
    else
        echo -e "${YELLOW}  Warning: Not on main branch (current: $current_branch)${NC}"
    fi
else
    test_failed "Not a git repository"
fi

# Test 10: Dry-run release-it
echo -e "${YELLOW}Test 10:${NC} Running release-it dry-run..."
if [ -d "node_modules/release-it" ]; then
    if npx release-it --dry-run --no-git.requireUpstream --ci 2>&1 | grep -q "release-it"; then
        test_passed "release-it dry-run executed successfully"
    else
        test_failed "release-it dry-run failed"
    fi
else
    test_failed "Cannot run dry-run - release-it not installed"
fi

# Summary
echo -e "\n${BLUE}=== Test Summary ===${NC}"
echo -e "Tests passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Tests failed: ${RED}${TESTS_FAILED}${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}✗ Some tests failed${NC}"
    exit 1
fi
