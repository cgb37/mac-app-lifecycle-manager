#!/usr/bin/env bash
# close-apps.sh - Shell wrapper for close-apps automation
# Part of mac-app-lifecycle-manager
#
# This script loads configuration, validates files, and invokes the AppleScript
# to close configured applications.

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
CONFIG_FILE="${REPO_ROOT}/config/close-apps.conf"

# Check if config file exists
if [[ ! -f "${CONFIG_FILE}" ]]; then
	log_error "Configuration file not found: ${CONFIG_FILE}"
	log_error "Create it by copying from: ${REPO_ROOT}/config/close-apps.conf.example"
	exit 2
fi

# Load configuration
log_debug "Loading configuration from: ${CONFIG_FILE}"
# shellcheck source=../../config/close-apps.conf.example
source "${CONFIG_FILE}" || die "Failed to load configuration file" 2

# Export REPO_ROOT and SCRIPT_DIR for use in config file variable expansion
export REPO_ROOT SCRIPT_DIR

# Apply variable expansion to configuration values
APP_LIST_PATH=$(eval echo "${APP_LIST_PATH}")
APPLESCRIPT_PATH=$(eval echo "${APPLESCRIPT_PATH}")
LOG_PATH=$(eval echo "${LOG_PATH}")
ERR_LOG_PATH=$(eval echo "${ERR_LOG_PATH}")

# =============================================================================
# VALIDATION
# =============================================================================

log_debug "Validating configuration..."

# Validate required commands
validate_command_exists "osascript" "AppleScript" || exit 1

# Validate app list file
validate_file_exists "${APP_LIST_PATH}" "App list file" || exit 2

# Validate AppleScript file
validate_file_exists "${APPLESCRIPT_PATH}" "AppleScript file" || exit 2

# Ensure log directory exists
LOG_DIR="$(dirname "${LOG_PATH}")"
ensure_dir "${LOG_DIR}" "Log directory"

# =============================================================================
# LOGGING SETUP
# =============================================================================

# Redirect all output to log files
exec 1> >(tee -a "${LOG_PATH}")
exec 2> >(tee -a "${ERR_LOG_PATH}" >&2)

# =============================================================================
# MAIN
# =============================================================================

main() {
	log_info "========================================="
	log_info "Close-Apps Starting"
	log_info "========================================="
	log_info "Config: ${CONFIG_FILE}"
	log_info "App list: ${APP_LIST_PATH}"
	log_info "AppleScript: ${APPLESCRIPT_PATH}"
	log_info "Quit timeout: ${QUIT_TIMEOUT}s"
	log_info "Close delay: ${CLOSE_DELAY}s"
	log_info "Log: ${LOG_PATH}"
	
	# Count apps to close
	local app_count
	app_count=$(grep -v '^#' "${APP_LIST_PATH}" | grep -v '^$' | wc -l | tr -d ' ')
	log_info "Apps to process: ${app_count}"
	
	# Execute AppleScript
	log_info "Executing AppleScript..."
	if /usr/bin/osascript "${APPLESCRIPT_PATH}" \
		"${APP_LIST_PATH}" \
		"${QUIT_TIMEOUT}" \
		"${CLOSE_DELAY}"; then
		log_info "Close-Apps completed successfully"
		log_info "========================================="
		exit 0
	else
		local exit_code=$?
		log_error "Close-Apps failed with exit code: ${exit_code}"
		log_info "========================================="
		exit "${exit_code}"
	fi
}

main "$@"
