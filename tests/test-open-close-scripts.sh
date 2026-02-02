#!/usr/bin/env bash
set -euo pipefail

# tests/test-open-close-scripts.sh
# Quick non-destructive tests for the open/close shell wrappers

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Running tests for open/close scripts..."

# Check npm scripts exist in package.json
if grep -q '"open-apps"' "${REPO_ROOT}/package.json"; then
  echo "npm script 'open-apps' found"
else
  echo "ERROR: npm script 'open-apps' not found in package.json" >&2
  exit 2
fi

if grep -q '"close-apps"' "${REPO_ROOT}/package.json"; then
  echo "npm script 'close-apps' found"
else
  echo "ERROR: npm script 'close-apps' not found in package.json" >&2
  exit 2
fi

# Ensure both wrapper scripts are present and executable
OPEN_SCRIPT="${REPO_ROOT}/scripts/open-apps/open-apps.sh"
CLOSE_SCRIPT="${REPO_ROOT}/scripts/close-apps/close-apps.sh"

for f in "${OPEN_SCRIPT}" "${CLOSE_SCRIPT}"; do
  if [[ -f "${f}" ]]; then
    echo "Found: ${f}"
  else
    echo "ERROR: Missing script: ${f}" >&2
    exit 3
  fi
  if [[ -x "${f}" ]]; then
    echo "Executable: ${f}"
  else
    echo "ERROR: Not executable: ${f}" >&2
    exit 4
  fi
done

# Syntax-check the bash scripts (non-executing)
bash -n "${OPEN_SCRIPT}"
echo "Syntax OK: open-apps.sh"
bash -n "${CLOSE_SCRIPT}"
echo "Syntax OK: close-apps.sh"

# Run non-destructive dry-run executions to verify logging and invocation
echo "Running dry-run executions (DRY_RUN=1)..."
DRY_RUN=1 bash "${OPEN_SCRIPT}" || {
  echo "ERROR: open-apps dry-run failed" >&2
  exit 5
}
echo "Dry-run OK: open-apps"

DRY_RUN=1 bash "${CLOSE_SCRIPT}" || {
  echo "ERROR: close-apps dry-run failed" >&2
  exit 6
}
echo "Dry-run OK: close-apps"

echo "All checks passed. To run the scripts manually, use:"
echo "  npm run open-apps"
echo "  npm run close-apps"

exit 0
