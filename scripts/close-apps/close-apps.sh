#!/usr/bin/env bash
# close-apps.sh - Shell wrapper for close-apps automation
# Part of mac-app-lifecycle-manager
# Version: 0.0.15
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
	# Support dry-run mode for tests: set DRY_RUN=1 to skip actual quitting
	if [[ "${DRY_RUN:-}" == "1" ]]; then
		log_info "DRY RUN: would execute osascript ${APPLESCRIPT_PATH} ${APP_LIST_PATH} ${QUIT_TIMEOUT} ${CLOSE_DELAY}"
		log_info "Close-Apps dry-run completed"
		exit 0
	fi

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
