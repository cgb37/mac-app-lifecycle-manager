# Logging & Log Rotation

This document describes the logging system used by mac-app-lifecycle-manager, including log rotation, retention policies, and troubleshooting.

## Overview

The logging system provides:

- **Centralized logging functions** - Standardized log levels (DEBUG, INFO, WARN, ERROR)
- **Automatic timestamps** - All log entries include `[YYYY-MM-DD HH:MM:SS]` timestamps
- **Dual output** - Logs written to files and displayed on console
- **Automatic log rotation** - Size and age-based rotation to prevent disk usage growth
- **Compressed archives** - Rotated logs are gzip-compressed to save space
- **Automatic cleanup** - Old rotated logs are automatically deleted

## Log Files

Each workflow (close-apps, open-apps) maintains two log files:

### Main Log (`*.log`)
- **Purpose**: Standard output (stdout) from wrapper script
- **Contains**: INFO/DEBUG messages from shell wrapper via `log_info()`, `log_debug()`
- **Location**: `logs/close-apps.log`, `logs/open-apps.log`

### Error Log (`*.err`)
- **Purpose**: Standard error (stderr) from AppleScript and shell errors
- **Contains**: AppleScript INFO/WARN/DEBUG output, shell stderr, error messages
- **Location**: `logs/close-apps.err`, `logs/open-apps.err`
- **Timestamps**: Automatically added by wrapper via stderr redirection

## Log Levels

| Level | Purpose | Output Stream | Example |
|-------|---------|---------------|---------|
| `DEBUG` | Detailed diagnostic info | stdout | `[DEBUG] Validating configuration...` |
| `INFO` | Normal operational messages | stdout | `[INFO] Closing ChatGPT` |
| `WARN` | Warning messages | stderr | `[WARN] App not found: /Applications/iTerm2.app` |
| `ERROR` | Error messages | stderr | `[ERROR] Configuration file not found` |

**Note**: DEBUG messages only appear when `LOG_LEVEL=DEBUG` is set in the config file.

## Log Rotation

### How It Works

Log rotation runs automatically at the **start of each wrapper script execution** (before any log entries are written). This ensures logs don't grow unbounded.

**Rotation triggers** (either condition triggers rotation):
1. **Age-based**: Log file is older than `LOG_RETENTION_DAYS` (default: 14 days)
2. **Size-based**: Log file exceeds `MAX_LOG_SIZE_MB` (default: 10 MB, set to 0 to disable)

**Rotation process**:
1. Check if log needs rotation (age or size threshold exceeded)
2. Compress current log with gzip: `close-apps.log` → `close-apps.log.1.gz`
3. Truncate original log file (start fresh)
4. Find and delete rotated logs older than retention period

### Configuration

Set these variables in your config files (`config/close-apps.conf`, `config/open-apps.conf`):

```bash
# Log retention period (days)
# Logs older than this will be deleted during rotation
# Default: 14
LOG_RETENTION_DAYS=14

# Maximum log file size (MB) before rotation
# Set to 0 to disable size-based rotation (age-based only)
# Default: 10
MAX_LOG_SIZE_MB=10
```

### Examples

**Age-based rotation only:**
```bash
LOG_RETENTION_DAYS=30
MAX_LOG_SIZE_MB=0  # Disable size-based rotation
```

**Size-based rotation only:**
```bash
LOG_RETENTION_DAYS=9999  # Effectively never rotate by age
MAX_LOG_SIZE_MB=5        # Rotate every 5 MB
```

**Aggressive rotation (small logs, frequent cleanup):**
```bash
LOG_RETENTION_DAYS=7
MAX_LOG_SIZE_MB=2
```

**Conservative rotation (keep more history):**
```bash
LOG_RETENTION_DAYS=90
MAX_LOG_SIZE_MB=50
```

## Rotated Log File Naming

Rotated logs are numbered sequentially and compressed:

```
logs/
├── close-apps.log          # Current active log
├── close-apps.log.1.gz     # Most recent rotation
├── close-apps.log.2.gz     # Second most recent
├── close-apps.log.3.gz     # Third most recent
├── close-apps.err          # Current error log
├── close-apps.err.1.gz     # Most recent error log rotation
└── ...
```

## Viewing Logs

### View Current Logs

**Main log (stdout):**
```bash
tail -f logs/close-apps.log
tail -f logs/open-apps.log
```

**Error log (stderr):**
```bash
tail -f logs/close-apps.err
tail -f logs/open-apps.err
```

**Both logs simultaneously:**
```bash
tail -f logs/close-apps.{log,err}
```

### View Rotated Logs

Rotated logs are gzip-compressed. Use `zless`, `zcat`, or `zgrep` to view:

```bash
# View compressed log with pager
zless logs/close-apps.log.1.gz

# Display entire compressed log
zcat logs/close-apps.log.1.gz

# Search in compressed log
zgrep "ERROR" logs/close-apps.log.*.gz
```

### Search Across All Logs (Active + Rotated)

```bash
# Search current and all rotated logs
grep "ChatGPT" logs/close-apps.log
zgrep "ChatGPT" logs/close-apps.log.*.gz

# Search for errors in last 7 days
find logs/ -name "close-apps.*.gz" -mtime -7 -exec zgrep "ERROR" {} +
```

## Log Structure Examples

### Main Log (stdout)
```
[2026-02-02 19:00:00] [INFO] =========================================
[2026-02-02 19:00:00] [INFO] Close-Apps Starting
[2026-02-02 19:00:00] [INFO] =========================================
[2026-02-02 19:00:00] [INFO] Config: /path/to/config/close-apps.conf
[2026-02-02 19:00:00] [INFO] App list: /path/to/config/apps-to-close.txt
[2026-02-02 19:00:00] [DEBUG] Loading configuration from: /path/to/config
[2026-02-02 19:00:01] [INFO] Apps to process: 18
[2026-02-02 19:00:01] [INFO] Executing AppleScript...
[2026-02-02 19:00:15] [INFO] Close-Apps completed successfully
[2026-02-02 19:00:15] [INFO] =========================================
```

### Error Log (stderr)
```
[2026-02-02 19:00:02] INFO: Closing apps by name...
[2026-02-02 19:00:02] INFO: Closing ChatGPT
[2026-02-02 19:00:03] INFO: Closing Google Chrome
[2026-02-02 19:00:04] DEBUG: Stickies not running
[2026-02-02 19:00:05] INFO: Closing apps by path...
[2026-02-02 19:00:05] INFO: Closing /Applications/Visual Studio Code.app
[2026-02-02 19:00:06] WARN: Failed to close /Applications/iTerm2.app: App not found
[2026-02-02 19:00:10] INFO: Force quitting stubborn apps...
[2026-02-02 19:00:10] DEBUG: pkill for thinkorswim: The command exited with a non-zero status.
[2026-02-02 19:00:12] INFO: App closing complete
```

## Disk Usage Management

### Estimate Disk Usage

```bash
# Current logs
du -sh logs/*.{log,err}

# Rotated logs
du -sh logs/*.gz

# Total log directory size
du -sh logs/
```

### Manual Cleanup

If automatic rotation isn't sufficient:

```bash
# Delete all rotated logs older than 30 days
find logs/ -name "*.gz" -mtime +30 -delete

# Delete all rotated logs (keep current logs)
rm -f logs/*.gz

# Archive logs before deletion (backup to external location)
tar -czf ~/backups/logs-$(date +%Y%m%d).tar.gz logs/
rm -f logs/*.gz
```

## Troubleshooting

### Problem: Logs not rotating

**Check rotation config:**
```bash
grep -E "LOG_RETENTION_DAYS|MAX_LOG_SIZE_MB" config/close-apps.conf
```

**Verify log file age and size:**
```bash
ls -lh logs/close-apps.log
stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" logs/close-apps.log  # macOS
```

**Check for rotation messages:**
```bash
grep "Rotating log" logs/close-apps.log
grep "Rotated to" logs/close-apps.log
```

### Problem: Rotated logs not being deleted

**Verify retention setting:**
```bash
grep LOG_RETENTION_DAYS config/close-apps.conf
```

**Check rotated log ages:**
```bash
find logs/ -name "*.gz" -exec stat -f "%Sm %N" -t "%Y-%m-%d" {} \;
```

**Manual cleanup:**
```bash
# Delete logs older than 14 days
find logs/ -name "*.gz" -mtime +14 -delete
```

### Problem: Disk space filling up

**Immediate mitigation:**
```bash
# Compress current logs manually
gzip logs/*.log logs/*.err

# Delete old rotated logs
find logs/ -name "*.gz" -mtime +7 -delete
```

**Long-term solution:**
```bash
# Reduce retention period
LOG_RETENTION_DAYS=7

# Reduce max size threshold
MAX_LOG_SIZE_MB=5
```

### Problem: Missing timestamps in error log

**Verify stderr redirection:**
```bash
# Check if setup_logging is called in wrapper script
grep "setup_logging" scripts/close-apps/close-apps.sh
```

**Check common.sh is sourced:**
```bash
# Verify common.sh exists and contains setup_logging
grep -A 10 "setup_logging()" scripts/lib/common.sh
```

### Problem: Can't view compressed logs

**Install gzip tools** (should be pre-installed on macOS):
```bash
which gzip zcat zless zgrep
```

**Alternative: decompress first:**
```bash
gunzip -c logs/close-apps.log.1.gz | less
```

## Implementation Details

### Log Rotation Functions (common.sh)

The logging system is implemented in `scripts/lib/common.sh`:

- **`setup_logging()`** - Main entry point, sets up stdout/stderr redirection with rotation
- **`rotate_logs()`** - Rotates both main and error logs
- **`rotate_log()`** - Rotates a single log file (checks age/size, compresses, truncates)
- **`cleanup_old_logs()`** - Deletes rotated logs older than retention period
- **`get_file_size()`** - Cross-platform file size check (macOS/Linux compatible)

### Wrapper Script Integration

Both `close-apps.sh` and `open-apps.sh` call `setup_logging()` after config loading:

```bash
# Setup logging with rotation
setup_logging "${LOG_PATH}" "${ERR_LOG_PATH}" "${LOG_RETENTION_DAYS:-14}" "${MAX_LOG_SIZE_MB:-0}"
```

This single function call:
1. Ensures log directory exists
2. Rotates logs if needed (based on age/size)
3. Sets up stdout redirection with tee (to file + console)
4. Sets up stderr redirection with timestamps and tee (to file + console)

## Best Practices

1. **Monitor disk usage periodically:**
   ```bash
   du -sh logs/
   ```

2. **Set appropriate retention for your use case:**
   - Daily runs: 14-30 days retention
   - Hourly runs: 7-14 days retention
   - Testing/development: 3-7 days retention

3. **Enable DEBUG logging only when troubleshooting:**
   ```bash
   LOG_LEVEL="DEBUG"  # Increases log volume significantly
   ```

4. **Review logs regularly for warnings/errors:**
   ```bash
   grep -E "WARN|ERROR" logs/close-apps.{log,err}
   ```

5. **Archive logs before major changes:**
   ```bash
   tar -czf logs-backup-$(date +%Y%m%d).tar.gz logs/
   ```

6. **Test rotation behavior manually:**
   ```bash
   # Create a large test log
   dd if=/dev/zero of=logs/test.log bs=1m count=15
   
   # Run wrapper to trigger rotation
   ./scripts/close-apps/close-apps.sh
   
   # Verify rotation occurred
   ls -lh logs/test.log*
   ```

## Future Enhancements

Potential improvements for consideration:

- [ ] Centralized log aggregation (send logs to remote syslog/logging service)
- [ ] Structured logging (JSON format for easier parsing)
- [ ] Log filtering by level in real-time
- [ ] Email notifications for ERROR-level events
- [ ] Log statistics/summary dashboard
- [ ] Integration with macOS Console.app
- [ ] Configurable log format templates

## See Also

- [CONFIGURATION.md](CONFIGURATION.md) - Configuration file reference
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - General troubleshooting guide
- [INSTALLATION.md](INSTALLATION.md) - Installation and setup instructions
