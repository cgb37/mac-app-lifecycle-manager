#!/usr/bin/env bash
# common.sh - Shared utility functions for mac-app-lifecycle scripts
#
# This library provides standardized logging, error handling, and validation
# functions used across all scripts in the mac-app-lifecycle system.

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================

# Get current timestamp in standardized format
timestamp() {
  date '+%Y-%m-%d %H:%M:%S'
}

# Log a message at INFO level
# Usage: log_info "Message text"
log_info() {
  local message="$1"
  echo "[$(timestamp)] [INFO] ${message}"
}

# Log a message at WARN level
# Usage: log_warn "Warning text"
log_warn() {
  local message="$1"
  echo "[$(timestamp)] [WARN] ${message}" >&2
}

# Log a message at ERROR level
# Usage: log_error "Error text"
log_error() {
  local message="$1"
  echo "[$(timestamp)] [ERROR] ${message}" >&2
}

# Log a message at DEBUG level (only if DEBUG mode enabled)
# Usage: log_debug "Debug text"
log_debug() {
  local message="$1"
  if [[ "${LOG_LEVEL:-INFO}" == "DEBUG" ]]; then
    echo "[$(timestamp)] [DEBUG] ${message}"
  fi
}

# Log a message with custom level
# Usage: log_message "LEVEL" "Message text"
log_message() {
  local level="$1"
  local message="$2"
  echo "[$(timestamp)] [${level}] ${message}"
}

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

# Check if a file exists and is readable
# Usage: validate_file_exists "/path/to/file" "Description"
# Returns: 0 if valid, 1 if not
validate_file_exists() {
  local file_path="$1"
  local description="${2:-File}"
  
  if [[ ! -f "${file_path}" ]]; then
    log_error "${description} not found: ${file_path}"
    return 1
  fi
  
  if [[ ! -r "${file_path}" ]]; then
    log_error "${description} is not readable: ${file_path}"
    return 1
  fi
  
  return 0
}

# Check if a directory exists
# Usage: validate_dir_exists "/path/to/dir" "Description"
# Returns: 0 if valid, 1 if not
validate_dir_exists() {
  local dir_path="$1"
  local description="${2:-Directory}"
  
  if [[ ! -d "${dir_path}" ]]; then
    log_error "${description} not found: ${dir_path}"
    return 1
  fi
  
  return 0
}

# Check if a command exists in PATH
# Usage: validate_command_exists "osascript" "AppleScript"
# Returns: 0 if exists, 1 if not
validate_command_exists() {
  local command_name="$1"
  local description="${2:-${command_name}}"
  
  if ! command -v "${command_name}" &> /dev/null; then
    log_error "${description} command not found: ${command_name}"
    return 1
  fi
  
  return 0
}

# =============================================================================
# ERROR HANDLING
# =============================================================================

# Exit with error message
# Usage: die "Error message" [exit_code]
die() {
  local message="$1"
  local exit_code="${2:-1}"
  
  log_error "${message}"
  exit "${exit_code}"
}

# =============================================================================
# FILE OPERATIONS
# =============================================================================

# Ensure a directory exists, creating it if necessary
# Usage: ensure_dir "/path/to/dir" "Description"
ensure_dir() {
  local dir_path="$1"
  local description="${2:-Directory}"
  
  if [[ ! -d "${dir_path}" ]]; then
    log_info "Creating ${description}: ${dir_path}"
    mkdir -p "${dir_path}" || die "Failed to create ${description}: ${dir_path}" 1
  fi
}

# =============================================================================
# CONFIGURATION LOADING
# =============================================================================

# Load configuration file with validation
# Usage: load_config "/path/to/config.conf"
# Returns: 0 if loaded successfully, 2 if config error
load_config() {
  local config_file="$1"
  
  if ! validate_file_exists "${config_file}" "Configuration file"; then
    return 2
  fi
  
  log_debug "Loading configuration from: ${config_file}"
  
  # Source the config file
  # shellcheck source=/dev/null
  source "${config_file}" || {
    log_error "Failed to load configuration file: ${config_file}"
    return 2
  }
  
  return 0
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Set strict error handling for scripts that source this library
set -euo pipefail

# Export functions for use in subshells if needed
export -f timestamp log_info log_warn log_error log_debug log_message
export -f validate_file_exists validate_dir_exists validate_command_exists
export -f die ensure_dir load_config
