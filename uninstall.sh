#!/bin/bash

# macOS App Lifecycle Manager - Uninstallation Script
# Version: 0.0.14

set -euo pipefail

# Source common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/lib/common.sh"

# Script variables
REPO_ROOT="$SCRIPT_DIR"
VERBOSE=false

# Confirm action
confirm() {
    local prompt="$1"
    local default="${2:-n}"

    read -p "$prompt (y/n) [$default]: " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || [[ -z "$REPLY" && "$default" == "y" ]]
}

# Unload launchd agent
unload_agent() {
    local label="$1"
    local plist="$2"

    if launchctl list | grep -q "$label"; then
        if launchctl unload "$plist"; then
            user_log_success "Unloaded launchd agent: $label"
        else
            user_log_warning "Failed to unload launchd agent: $label"
        fi
    else
        user_log_info "Launchd agent not loaded: $label"
    fi
}

# Remove file if exists
remove_file() {
    local file="$1"
    local description="$2"

    if [[ -f "$file" ]]; then
        rm "$file"
        user_log_success "Removed $description: $file"
    else
        user_log_info "$description not found: $file"
    fi
}

# Remove directory if exists and empty
remove_dir_if_empty() {
    local dir="$1"
    local description="$2"

    if [[ -d "$dir" ]]; then
        if [[ -z "$(ls -A "$dir" 2>/dev/null)" ]]; then
            rmdir "$dir"
            user_log_success "Removed empty $description: $dir"
        else
            user_log_info "$description not empty, keeping: $dir"
        fi
    else
        user_log_info "$description not found: $dir"
    fi
}

# Main uninstallation function
main() {
    echo "macOS App Lifecycle Manager - Uninstallation"
    echo "=========================================="
    echo

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --verbose)
                VERBOSE=true
                ;;
            *)
                user_log_error "Unknown option: $1"
                echo "Usage: $0 [--verbose]"
                exit 1
                ;;
        esac
        shift
    done

    # Confirm uninstallation
    if ! confirm "This will uninstall macOS App Lifecycle Manager. Continue?"; then
        user_log_info "Uninstallation cancelled"
        exit 0
    fi

    # Unload launchd agents
    user_log_info "Unloading launchd agents..."
    unload_agent "com.user.mac-app-lifecycle.close" "$HOME/Library/LaunchAgents/com.user.mac-app-lifecycle.close.plist"
    unload_agent "com.user.mac-app-lifecycle.open" "$HOME/Library/LaunchAgents/com.user.mac-app-lifecycle.open.plist"

    # Remove plist files
    user_log_info "Removing launchd plist files..."
    remove_file "$HOME/Library/LaunchAgents/com.user.mac-app-lifecycle.close.plist" "close plist"
    remove_file "$HOME/Library/LaunchAgents/com.user.mac-app-lifecycle.open.plist" "open plist"

    # Remove LaunchAgents directory if empty
    remove_dir_if_empty "$HOME/Library/LaunchAgents" "LaunchAgents directory"

    # Handle config files
    if [[ -f "config/close-apps.conf" || -f "config/open-apps.conf" || -f "config/apps-to-close.txt" || -f "config/apps-to-open.txt" ]]; then
        if confirm "Remove configuration files (close-apps.conf, open-apps.conf, apps-to-close.txt, apps-to-open.txt)?"; then
            remove_file "config/close-apps.conf" "close-apps config"
            remove_file "config/open-apps.conf" "open-apps config"
            remove_file "config/apps-to-close.txt" "apps-to-close list"
            remove_file "config/apps-to-open.txt" "apps-to-open list"
            remove_dir_if_empty "config" "config directory"
        else
            user_log_info "Keeping configuration files"
        fi
    fi

    # Handle logs
    if [[ -d "logs" ]]; then
        if confirm "Remove log files and logs directory?"; then
            # Remove log files
            remove_file "logs/close-apps.log" "close-apps log"
            remove_file "logs/close-apps.err" "close-apps error log"
            remove_file "logs/open-apps.log" "open-apps log"
            remove_file "logs/open-apps.err" "open-apps error log"
            remove_dir_if_empty "logs" "logs directory"
        else
            user_log_info "Keeping log files"
        fi
    fi

    user_log_success "Uninstallation completed successfully!"
    echo
    user_log_info "Note: macOS permissions (Accessibility, Automation) are not automatically removed."
    user_log_info "You can remove them manually in System Settings → Privacy & Security."
}

# Run main function
main "$@"