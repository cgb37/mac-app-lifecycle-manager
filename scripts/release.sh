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
DRY_RUN=""

case "${RELEASE_TYPE}" in
    major)
        echo -e "${GREEN}Starting major release...${NC}"
        npx release-it major
        ;;
    minor)
        echo -e "${GREEN}Starting minor release...${NC}"
        npx release-it minor
        ;;
    patch)
        echo -e "${GREEN}Starting patch release...${NC}"
        npx release-it patch
        ;;
    set)
        echo -e "${GREEN}Set specific version...${NC}"
        npx release-it --no-increment
        ;;
    --dry-run)
        echo -e "${YELLOW}Running in dry-run mode...${NC}"
        npx release-it --dry-run
        ;;
    "")
        echo -e "${GREEN}Starting interactive release (auto-detect version bump)...${NC}"
        npx release-it
        ;;
    *)
        echo -e "${RED}Error: Unknown release type '${RELEASE_TYPE}'${NC}"
        echo "Usage: $0 [major|minor|patch|set|--dry-run]"
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
