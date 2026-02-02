#!/usr/bin/env bash
# common.sh - Shared utility functions for mac-app-lifecycle scripts
# Version: 0.0.12
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
    echo "[$(timestamp)] [DEBUG] ${message}" >&2
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

# Get file size in bytes (cross-platform)
# Usage: get_file_size "/path/to/file"
# Returns: size in bytes, or 0 if file doesn't exist
get_file_size() {
  local file_path="$1"
  
  if [[ ! -f "${file_path}" ]]; then
    echo "0"
    return
  fi
  
  # macOS uses 'stat -f %z', Linux uses 'stat -c %s'
  if stat -f%z "${file_path}" 2>/dev/null; then
    return
  elif stat -c%s "${file_path}" 2>/dev/null; then
    return
  else
    echo "0"
  fi
}

# =============================================================================
# LOG ROTATION
# =============================================================================

# Rotate a single log file if it exceeds size or age limits
# Usage: rotate_log "/path/to/file.log" retention_days max_size_mb
# Example: rotate_log "/tmp/app.log" 14 10
rotate_log() {
  local log_file="$1"
  local retention_days="${2:-14}"
  local max_size_mb="${3:-0}"
  
  # Skip if log file doesn't exist
  [[ ! -f "${log_file}" ]] && return 0
  
  local should_rotate=false
  local rotation_reason=""
  
  # Check size-based rotation (if max_size_mb > 0)
  if awk "BEGIN {exit !(${max_size_mb} > 0)}"; then
    local file_size_bytes
    file_size_bytes=$(get_file_size "${log_file}")
    local max_size_bytes
    max_size_bytes=$(awk "BEGIN {printf \"%d\", ${max_size_mb} * 1024 * 1024}")
    
    if [[ "${file_size_bytes}" -gt "${max_size_bytes}" ]]; then
      should_rotate=true
      rotation_reason="size exceeded ${max_size_mb}MB"
    fi
  fi
  
  # Check age-based rotation
  if [[ -f "${log_file}" ]]; then
    local file_age_days
    local current_time
    local file_mtime
    
    current_time=$(date +%s)
    
    # macOS uses 'stat -f %m', Linux uses 'stat -c %Y'
    if file_mtime=$(stat -f %m "${log_file}" 2>/dev/null); then
      :
    elif file_mtime=$(stat -c %Y "${log_file}" 2>/dev/null); then
      :
    else
      file_mtime="${current_time}"
    fi
    
    file_age_days=$(( (current_time - file_mtime) / 86400 ))
    
    if [[ "${file_age_days}" -ge "${retention_days}" ]]; then
      should_rotate=true
      rotation_reason="age ${file_age_days} days (retention: ${retention_days} days)"
    fi
  fi
  
  # Perform rotation if needed
  if [[ "${should_rotate}" == "true" ]]; then
    log_debug "Rotating log: ${log_file} (${rotation_reason})"
    
    # Find next available rotation number
    local rotation_num=1
    while [[ -f "${log_file}.${rotation_num}.gz" ]]; do
      rotation_num=$((rotation_num + 1))
    done
    
    # Compress and rotate the log
    if gzip -c "${log_file}" > "${log_file}.${rotation_num}.gz" 2>/dev/null; then
      # Truncate the original log file
      > "${log_file}"
      log_debug "Rotated to: ${log_file}.${rotation_num}.gz"
    else
      log_warn "Failed to compress log file: ${log_file}"
    fi
  fi
  
  # Clean up old rotated logs
  cleanup_old_logs "$(dirname "${log_file}")" "$(basename "${log_file}")" "${retention_days}"
}

# Clean up old rotated log files
# Usage: cleanup_old_logs "/path/to/log/dir" "basename.log" retention_days
cleanup_old_logs() {
  local log_dir="$1"
  local log_basename="$2"
  local retention_days="${3:-14}"
  local current_time
  current_time=$(date +%s)
  local cutoff_time=$((current_time - (retention_days * 86400)))
  
  # Find all rotated logs matching pattern
  find "${log_dir}" -name "${log_basename}.*.gz" -type f 2>/dev/null | while IFS= read -r rotated_log; do
    local file_mtime
    
    # Get file modification time
    if file_mtime=$(stat -f %m "${rotated_log}" 2>/dev/null); then
      :
    elif file_mtime=$(stat -c %Y "${rotated_log}" 2>/dev/null); then
      :
    else
      continue
    fi
    
    # Delete if older than retention period
    if [[ "${file_mtime}" -lt "${cutoff_time}" ]]; then
      log_debug "Deleting old log: ${rotated_log}"
      rm -f "${rotated_log}"
    fi
  done
}

# Rotate logs for a script (both main log and error log)
# Usage: rotate_logs "/path/to/main.log" "/path/to/error.log" retention_days max_size_mb
rotate_logs() {
  local main_log="$1"
  local err_log="$2"
  local retention_days="${3:-14}"
  local max_size_mb="${4:-0}"
  
  rotate_log "${main_log}" "${retention_days}" "${max_size_mb}"
  rotate_log "${err_log}" "${retention_days}" "${max_size_mb}"
}

# =============================================================================
# LOGGING SETUP
# =============================================================================

# Setup logging redirections with timestamps
# Usage: setup_logging "/path/to/main.log" "/path/to/error.log" [retention_days] [max_size_mb]
# This function:
# - Rotates logs if needed
# - Redirects stdout to main log (with tee for console output)
# - Filters stderr by log level: INFO/WARN → main log, ERROR/DEBUG → error log
setup_logging() {
  local main_log="$1"
  local err_log="$2"
  local retention_days="${3:-14}"
  local max_size_mb="${4:-0}"
  
  # Ensure log directory exists
  local log_dir
  log_dir=$(dirname "${main_log}")
  ensure_dir "${log_dir}" "Log directory"
  
  # Rotate logs if needed
  rotate_logs "${main_log}" "${err_log}" "${retention_days}" "${max_size_mb}"
  
  # Redirect stdout to main log (preserve timestamps from log_* functions)
  exec 1> >(tee -a "${main_log}")
  
  # Redirect stderr through filter that routes by log level
  exec 2> >(while IFS= read -r line; do
    # Add timestamp if not already present
    local timestamped_line
    if [[ "$line" =~ ^\[[0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
      timestamped_line="$line"
    else
      timestamped_line="[$(date '+%Y-%m-%d %H:%M:%S')] $line"
    fi
    
    # Route based on log level
    if [[ "$line" =~ ^(INFO:|WARN:) ]] || [[ "$line" =~ \[(INFO|WARN)\] ]]; then
      # INFO and WARN go to main log
      echo "$timestamped_line" >> "${main_log}"
      echo "$timestamped_line" >&2
    else
      # ERROR, DEBUG, and everything else go to error log
      echo "$timestamped_line" >> "${err_log}"
      echo "$timestamped_line" >&2
    fi
  done)
}

# =============================================================================
# CONFIGURATION LOADING
# =============================================================================

# Load configuration file with validation
# Usage: load_config "/path/to/config.conf"
# Returns: 0 if loaded successfully, 2 if config error
# Note: Exports REPO_ROOT and SCRIPT_DIR for variable expansion in config
load_config() {
  local config_file="$1"
  
  if ! validate_file_exists "${config_file}" "Configuration file"; then
    return 2
  fi
  
  log_debug "Loading configuration from: ${config_file}"
  
  # Export REPO_ROOT and SCRIPT_DIR for use in config file
  export REPO_ROOT SCRIPT_DIR
  
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
export -f die ensure_dir load_config get_file_size
export -f rotate_log cleanup_old_logs rotate_logs setup_logging
