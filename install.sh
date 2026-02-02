#!/bin/bash

# macOS App Lifecycle Manager - Installation Script
# Version: 0.0.14

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script variables
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
VERBOSE=false

# Logging functions
log_info() {
    echo -e "${BLUE}INFO:${NC} $1"
}

log_success() {
    echo -e "${GREEN}SUCCESS:${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

log_error() {
    echo -e "${RED}ERROR:${NC} $1" >&2
}

# Validate time format (HH:MM)
validate_time() {
    local time="$1"
    if [[ ! "$time" =~ ^([01]?[0-9]|2[0-3]):[0-5][0-9]$ ]]; then
        return 1
    fi
    return 0
}

# Prompt for time with validation
prompt_time() {
    local prompt="$1"
    local default="$2"
    local time

    while true; do
        read -p "$prompt [$default]: " time
        time="${time:-$default}"

        if validate_time "$time"; then
            echo "$time"
            return 0
        else
            log_error "Invalid time format. Please use HH:MM (24-hour format)."
        fi
    done
}

# Check if file exists and prompt to edit
handle_existing_file() {
    local file="$1"
    local description="$2"

    if [[ -f "$file" ]]; then
        log_warning "$description already exists at $file"
        read -p "Do you want to edit it now? (y/n) [n]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            ${EDITOR:-nano} "$file"
        fi
        return 1
    fi
    return 0
}

# Copy example to config file
copy_config() {
    local example="$1"
    local config="$2"
    local description="$3"

    if handle_existing_file "$config" "$description"; then
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "[DRY RUN] Would copy $example to $config"
        else
            cp "$example" "$config"
            log_success "Created $description"
        fi
    fi
}

# Generate plist from template
generate_plist() {
    local template="$1"
    local output="$2"
    local time="$3"
    local log_path="$4"
    local err_log_path="$5"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would generate plist $output from $template"
        return
    fi

    # Split time into hour and minute
    IFS=':' read -r schedule_hour schedule_minute <<< "$time"

    # Use sed to replace placeholders
    sed \
        -e "s|{{REPO_ROOT}}|$REPO_ROOT|g" \
        -e "s|{{SCHEDULE_HOUR}}|$schedule_hour|g" \
        -e "s|{{SCHEDULE_MINUTE}}|$schedule_minute|g" \
        -e "s|{{LOG_PATH}}|$log_path|g" \
        -e "s|{{ERR_LOG_PATH}}|$err_log_path|g" \
        -e "s|{{WEEKDAYS_ENTRY}}||g" \
        "$template" > "$output"

    log_success "Generated plist: $output"
}

# Set executable permissions
set_permissions() {
    local files=("$@")

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would set executable permissions on: ${files[*]}"
        return
    fi

    chmod +x "${files[@]}"
    log_success "Set executable permissions"
}

# Load launchd agent
load_agent() {
    local plist="$1"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would load launchd agent: $plist"
        return
    fi

    if launchctl load "$plist"; then
        log_success "Loaded launchd agent: $(basename "$plist")"
    else
        log_error "Failed to load launchd agent: $(basename "$plist")"
        return 1
    fi
}

# Validate installation
validate_installation() {
    local issues=0

    # Check config files
    for config in "close-apps.conf" "open-apps.conf" "apps-to-close.txt" "apps-to-open.txt"; do
        if [[ ! -f "config/$config" ]]; then
            log_error "Missing config file: config/$config"
            ((issues++))
        fi
    done

    # Check logs directory
    if [[ ! -d "logs" ]]; then
        log_error "Missing logs directory"
        ((issues++))
    fi

    # Check plist files
    for plist in "com.user.mac-app-lifecycle.close.plist" "com.user.mac-app-lifecycle.open.plist"; do
        if [[ ! -f "$HOME/Library/LaunchAgents/$plist" ]]; then
            log_error "Missing launchd plist: $HOME/Library/LaunchAgents/$plist"
            ((issues++))
        fi
    done

    # Check agent status
    for label in "com.user.mac-app-lifecycle.close" "com.user.mac-app-lifecycle.open"; do
        if ! launchctl list | grep -q "$label"; then
            log_error "Launchd agent not loaded: $label"
            ((issues++))
        fi
    done

    # Check permissions
    for script in "bin/mac-app-lifecycle" "scripts/close-apps/close-apps.sh" "scripts/open-apps/open-apps.sh"; do
        if [[ ! -x "$script" ]]; then
            log_error "Missing executable permission: $script"
            ((issues++))
        fi
    done

    if [[ $issues -eq 0 ]]; then
        log_success "Installation validation passed"
        return 0
    else
        log_error "Installation validation failed with $issues issues"
        return 1
    fi
}

# Print permission instructions
print_permission_instructions() {
    echo
    log_info "IMPORTANT: macOS Permissions Setup"
    echo
    echo "This tool requires macOS permissions to control applications:"
    echo
    echo "1. Accessibility Permissions:"
    echo "   - Open System Settings → Privacy & Security → Accessibility"
    echo "   - Add and enable Terminal.app (or your terminal)"
    echo
    echo "2. Automation Permissions:"
    echo "   - Open System Settings → Privacy & Security → Automation"
    echo "   - Find your terminal app in the list"
    echo "   - Enable automation for the apps you want to control"
    echo
    echo "3. Full Disk Access (if needed):"
    echo "   - Open System Settings → Privacy & Security → Full Disk Access"
    echo "   - Add Terminal.app"
    echo
    echo "After setting permissions, restart your terminal and test with:"
    echo "  ./bin/mac-app-lifecycle close --now"
    echo
}

# Main installation function
main() {
    echo "macOS App Lifecycle Manager - Installation"
    echo "========================================"
    echo

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                log_warning "DRY RUN MODE - No changes will be made"
                ;;
            --verbose)
                VERBOSE=true
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Usage: $0 [--dry-run] [--verbose]"
                exit 1
                ;;
        esac
        shift
    done

    # Validate environment
    if [[ "$(uname)" != "Darwin" ]]; then
        log_error "This script is for macOS only"
        exit 1
    fi

    # Check macOS version (10.15+)
    if ! sw_vers -productVersion | awk -F. '{ if ($1 < 10 || ($1 == 10 && $2 < 15)) exit 1 }'; then
        log_error "macOS 10.15 (Catalina) or later required"
        exit 1
    fi

    # Check required commands
    for cmd in osascript launchctl; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            log_error "Required command not found: $cmd"
            exit 1
        fi
    done

    # Prompt for schedule times
    echo "Configure schedules (24-hour format):"
    CLOSE_TIME=$(prompt_time "Close apps time" "19:00")
    OPEN_TIME=$(prompt_time "Open apps time" "08:00")
    echo

    # Copy config files
    log_info "Setting up configuration files..."
    copy_config "config/close-apps.conf.example" "config/close-apps.conf" "close-apps configuration"
    copy_config "config/open-apps.conf.example" "config/open-apps.conf" "open-apps configuration"
    copy_config "config/apps-to-close.txt.example" "config/apps-to-close.txt" "apps-to-close list"
    copy_config "config/apps-to-open.txt.example" "config/apps-to-open.txt" "apps-to-open list"

    # Create logs directory
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would create logs directory"
    else
        mkdir -p logs
        log_success "Created logs directory"
    fi

    # Generate plist files
    log_info "Generating launchd plist files..."
    generate_plist "launchd/com.user.mac-app-lifecycle.close.plist.template" \
                   "$HOME/Library/LaunchAgents/com.user.mac-app-lifecycle.close.plist" \
                   "$CLOSE_TIME" \
                   "$REPO_ROOT/logs/close-apps.log" \
                   "$REPO_ROOT/logs/close-apps.err"

    generate_plist "launchd/com.user.mac-app-lifecycle.open.plist.template" \
                   "$HOME/Library/LaunchAgents/com.user.mac-app-lifecycle.open.plist" \
                   "$OPEN_TIME" \
                   "$REPO_ROOT/logs/open-apps.log" \
                   "$REPO_ROOT/logs/open-apps.err"

    # Set permissions
    log_info "Setting executable permissions..."
    set_permissions "bin/mac-app-lifecycle" \
                    "scripts/close-apps/close-apps.sh" \
                    "scripts/open-apps/open-apps.sh"

    # Load launchd agents
    log_info "Loading launchd agents..."
    load_agent "$HOME/Library/LaunchAgents/com.user.mac-app-lifecycle.close.plist"
    load_agent "$HOME/Library/LaunchAgents/com.user.mac-app-lifecycle.open.plist"

    # Validate installation
    log_info "Validating installation..."
    if validate_installation; then
        log_success "Installation completed successfully!"
        print_permission_instructions
    else
        log_error "Installation completed with issues. Please check the errors above."
        exit 1
    fi
}

# Run main function
main "$@"