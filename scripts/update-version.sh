#!/usr/bin/env bash
#
# Update version across all project files
# Called by release-it after version bump in package.json
#
# Usage: ./scripts/update-version.sh <version>
# Example: ./scripts/update-version.sh 1.2.3

set -euo pipefail

# Check arguments
if [ $# -ne 1 ]; then
    echo "Error: Version argument required"
    echo "Usage: $0 <version>"
    exit 1
fi

VERSION="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Updating version to ${VERSION} across project files..."

# Update shell scripts version comments
update_shell_script() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "Warning: $file not found, skipping"
        return
    fi
    
    # Update version comment if it exists
    if grep -q "^# Version: " "$file" 2>/dev/null; then
        sed -i.bak "s/^# Version: .*/# Version: ${VERSION}/" "$file"
        rm -f "${file}.bak"
        echo "  ✓ Updated $file"
    fi
}

# Update launchd plist templates
update_plist_template() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "Warning: $file not found, skipping"
        return
    fi
    
    # Update version comment if it exists
    if grep -q "<!-- Version: " "$file" 2>/dev/null; then
        sed -i.bak "s/<!-- Version: .* -->/<!-- Version: ${VERSION} -->/" "$file"
        rm -f "${file}.bak"
        echo "  ✓ Updated $file"
    fi
}

# Update documentation
update_documentation() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "Warning: $file not found, skipping"
        return
    fi
    
    # Update version badges or references
    if grep -q "Version: \*\*" "$file" 2>/dev/null; then
        sed -i.bak "s/Version: \*\*[^*]*\*\*/Version: **${VERSION}**/" "$file"
        rm -f "${file}.bak"
        echo "  ✓ Updated $file"
    fi
}

cd "${PROJECT_ROOT}"

# Update shell scripts
echo "Updating shell scripts..."
update_shell_script "scripts/close-apps/close-apps.sh"
update_shell_script "scripts/open-apps/open-apps.sh"
update_shell_script "scripts/lib/common.sh"
update_shell_script "bin/mac-app-lifecycle"

# Update launchd templates
echo "Updating launchd templates..."
update_plist_template "launchd/com.user.mac-app-lifecycle.close.plist.template"
update_plist_template "launchd/com.user.mac-app-lifecycle.open.plist.template"

# Update documentation
echo "Updating documentation..."
update_documentation "README.md"
update_documentation "docs/INSTALLATION.md"

# Git add updated files
echo "Staging updated files..."
git add -u

echo "✓ Version update complete!"
