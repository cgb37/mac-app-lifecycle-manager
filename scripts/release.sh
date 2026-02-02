#!/usr/bin/env bash
#
# Release wrapper script for mac-app-lifecycle-manager
# Provides convenient release commands using release-it with conventional-changelog
#
# Usage:
#   ./scripts/release.sh           # Interactive release (auto-detects version bump)
#   ./scripts/release.sh major     # Force major version bump
#   ./scripts/release.sh minor     # Force minor version bump
#   ./scripts/release.sh patch     # Force patch version bump
#   ./scripts/release.sh set       # Set specific version
#   ./scripts/release.sh --dry-run # Dry run mode

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Ensure we're in the project root
cd "${PROJECT_ROOT}"

# Debug: Check if GITHUB_TOKEN is in environment
if [ -n "${GITHUB_TOKEN:-}" ]; then
    echo -e "${GREEN}✓ GITHUB_TOKEN found in environment (${#GITHUB_TOKEN} chars)${NC}"
fi

# Load .env file if it exists and GITHUB_TOKEN is not already set
if [ -z "${GITHUB_TOKEN:-}" ] && [ -f ".env" ]; then
    echo -e "${YELLOW}Loading GITHUB_TOKEN from .env file...${NC}"
    # shellcheck disable=SC1091
    source .env
fi

# Verify GITHUB_TOKEN is set
if [ -z "${GITHUB_TOKEN:-}" ]; then
    echo -e "${RED}Error: GITHUB_TOKEN not set${NC}"
    echo "Please either:"
    echo "  1. Export in shell: export GITHUB_TOKEN='your_token'"
    echo "  2. Create .env file: cp .env.example .env (and add your token)"
    echo ""
    echo "Generate token at: https://github.com/settings/tokens (needs 'repo' scope)"
    exit 1
fi

# Export for child processes
export GITHUB_TOKEN

# Check if release-it is installed
if ! command -v npx &> /dev/null; then
    echo -e "${RED}Error: npx not found. Please install Node.js and npm.${NC}"
    exit 1
fi

if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}Warning: node_modules not found. Running npm install...${NC}"
    npm install
fi

# Parse arguments
RELEASE_TYPE="${1:-}"
shift || true  # Remove first arg, continue if none left
EXTRA_ARGS="$@"  # Capture remaining arguments

case "${RELEASE_TYPE}" in
    major)
        echo -e "${GREEN}Starting major release...${NC}"
        GITHUB_TOKEN="${GITHUB_TOKEN}" npx release-it major ${EXTRA_ARGS}
        ;;
    minor)
        echo -e "${GREEN}Starting minor release...${NC}"
        GITHUB_TOKEN="${GITHUB_TOKEN}" npx release-it minor ${EXTRA_ARGS}
        ;;
    patch)
        echo -e "${GREEN}Starting patch release...${NC}"
        GITHUB_TOKEN="${GITHUB_TOKEN}" npx release-it patch ${EXTRA_ARGS}
        ;;
    set)
        echo -e "${GREEN}Set specific version...${NC}"
        GITHUB_TOKEN="${GITHUB_TOKEN}" npx release-it --no-increment ${EXTRA_ARGS}
        ;;
    --dry-run)
        echo -e "${YELLOW}Running in dry-run mode...${NC}"
        GITHUB_TOKEN="${GITHUB_TOKEN}" npx release-it --dry-run ${EXTRA_ARGS}
        ;;
    "")
        echo -e "${GREEN}Starting interactive release (auto-detect version bump)...${NC}"
        GITHUB_TOKEN="${GITHUB_TOKEN}" npx release-it ${EXTRA_ARGS} --ci
        ;;
    *)
        echo -e "${RED}Error: Unknown release type '${RELEASE_TYPE}'${NC}"
        echo "Usage: $0 [major|minor|patch|set|--dry-run] [additional release-it flags]"
        exit 1
        ;;
esac

# Success message
if [ "${RELEASE_TYPE}" != "--dry-run" ]; then
    echo -e "${GREEN}Release complete!${NC}"
    echo "Don't forget to:"
    echo "  1. Check the GitHub release page"
    echo "  2. Verify CHANGELOG.md was updated"
    echo "  3. Confirm git tags were pushed"
fi
