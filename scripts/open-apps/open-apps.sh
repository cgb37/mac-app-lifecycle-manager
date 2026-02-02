#!/usr/bin/env bash
# open-apps.sh - Shell wrapper for open-apps automation
# Part of mac-app-lifecycle-manager
# Version: 0.0.9
#
# This script loads configuration, validates files, and invokes the AppleScript
# to open whitelisted applications.

set -euo pipefail

# =============================================================================
# SETUP
# =============================================================================

# Determine script directory and repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Source common library
# shellcheck source=../lib/common.sh
if [[ -f "${SCRIPT_DIR}/../lib/common.sh" ]]; then
	source "${SCRIPT_DIR}/../lib/common.sh"
else
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] common.sh library not found" >&2
	exit 1
fi

# =============================================================================
# CONFIGURATION
# =============================================================================

# Default configuration file location
CONFIG_FILE="${REPO_ROOT}/config/open-apps.conf"

# Check if config file exists
if [[ ! -f "${CONFIG_FILE}" ]]; then
	log_error "Configuration file not found: ${CONFIG_FILE}"
	log_error "Create it by copying from: ${REPO_ROOT}/config/open-apps.conf.example"
	exit 2
fi

# Load configuration
log_debug "Loading configuration from: ${CONFIG_FILE}"
# shellcheck source=../../config/open-apps.conf.example
source "${CONFIG_FILE}" || die "Failed to load configuration file" 2

# Export REPO_ROOT and SCRIPT_DIR for use in config file variable expansion
export REPO_ROOT SCRIPT_DIR

# Apply variable expansion to configuration values
WHITELIST_PATH=$(eval echo "${WHITELIST_PATH}")
PRIMARY_APP_PATH=$(eval echo "${PRIMARY_APP_PATH:-}")
APPLESCRIPT_PATH=$(eval echo "${APPLESCRIPT_PATH}")
LOG_PATH=$(eval echo "${LOG_PATH}")
ERR_LOG_PATH=$(eval echo "${ERR_LOG_PATH}")

# =============================================================================
# VALIDATION
# =============================================================================

log_debug "Validating configuration..."

# Validate required commands
validate_command_exists "osascript" "AppleScript" || exit 1

# Validate whitelist file
validate_file_exists "${WHITELIST_PATH}" "Whitelist file" || exit 2

# Validate AppleScript file
validate_file_exists "${APPLESCRIPT_PATH}" "AppleScript file" || exit 2

# Validate primary app path if set
if [[ -n "${PRIMARY_APP_PATH}" && "${PRIMARY_APP_PATH}" != "" ]]; then
	if [[ ! -e "${PRIMARY_APP_PATH}" ]]; then
		log_warn "Primary app path does not exist: ${PRIMARY_APP_PATH}"
		log_warn "Continuing without primary app"
		PRIMARY_APP_PATH=""
	fi
fi

# =============================================================================
# LOGGING SETUP
# =============================================================================

# Setup logging with rotation
setup_logging "${LOG_PATH}" "${ERR_LOG_PATH}" "${LOG_RETENTION_DAYS:-14}" "${MAX_LOG_SIZE_MB:-0}"

# =============================================================================
# MAIN
# =============================================================================

main() {
	log_info "========================================="
	log_info "Open-Apps Starting"
	log_info "========================================="
	log_info "Config: ${CONFIG_FILE}"
	log_info "Whitelist: ${WHITELIST_PATH}"
	log_info "AppleScript: ${APPLESCRIPT_PATH}"
	log_info "Primary app: ${PRIMARY_APP_PATH:-none}"
	log_info "Stagger delay: ${STAGGER_DELAY}s"
	log_info "Post-launch delay: ${POST_LAUNCH_DELAY}s"
	log_info "Skip running: ${SKIP_RUNNING}"
	log_info "Log: ${LOG_PATH}"
	
	# Count apps to open
	local app_count
	app_count=$(grep -v '^#' "${WHITELIST_PATH}" | grep -v '^$' | wc -l | tr -d ' ')
	log_info "Apps to open: ${app_count}"
	
	# Execute AppleScript
	log_info "Executing AppleScript..."
	if /usr/bin/osascript "${APPLESCRIPT_PATH}" \
		"${WHITELIST_PATH}" \
		"${PRIMARY_APP_PATH:-}" \
		"${STAGGER_DELAY}" \
		"${POST_LAUNCH_DELAY}" \
		"${SKIP_RUNNING}"; then
		log_info "Open-Apps completed successfully"
		log_info "========================================="
		exit 0
	else
		local exit_code=$?
		log_error "Open-Apps failed with exit code: ${exit_code}"
		log_info "========================================="
		exit "${exit_code}"
	fi
}

main "$@"
