# Configuration System

This directory contains configuration templates for the macOS App Lifecycle Manager.

## Configuration Files

### close-apps.conf
Controls the behavior of the close-apps automation:
- Which apps to close
- When to close them
- How aggressively to quit them
- Where to log activity

### open-apps.conf
Controls the behavior of the open-apps automation:
- Which apps to open
- When to open them
- Launch timing and delays
- Primary app preference

## Installation

Configuration files stay in the repository:

```bash
# Clone repository
cd mac-app-lifecycle-manager

# Copy templates to create your local configs (gitignored)
cp config/close-apps.conf.example config/close-apps.conf
cp config/open-apps.conf.example config/open-apps.conf
cp config/apps-to-close.txt.example config/apps-to-close.txt
cp config/apps-to-open.txt.example config/apps-to-open.txt

# Edit your configs
vim config/close-apps.conf
vim config/apps-to-close.txt
```

The install script will check for these files and create them if missing.

## Customization

1. Copy the `.example` files to your config directory (see above)
2. Edit the copied files (not the `.example` files)
3. Customize paths, schedules, and behavior settings
4. Test manually before enabling scheduled automation

## Key Configuration Options

### Paths
- `APP_LIST_PATH` / `WHITELIST_PATH` - Location of app lists (default: `config/apps-to-*.txt`)
- `APPLESCRIPT_PATH` - Location of AppleScript files (default: auto-detected)
- `LOG_PATH` - Where to write logs (default: `logs/` in repo)

### Schedule
- `SCHEDULE_HOUR` - Hour to run (0-23, 24-hour format)
- `SCHEDULE_MINUTE` - Minute to run (0-59)
- `SCHEDULE_WEEKDAYS` - Optional: Limit to specific days (e.g., "1,2,3,4,5" for weekdays)

### Behavior (close-apps)
- `QUIT_TIMEOUT` - How long to wait for graceful quit
- `CLOSE_DELAY` - Pause between closing apps
- `RETRY_COUNT` - Attempts before force quitting

### Behavior (open-apps)
- `STAGGER_DELAY` - Pause between launching apps
- `POST_LAUNCH_DELAY` - Wait time after all apps launch
- `SKIP_RUNNING` - Don't relaunch already-running apps
- `PRIMARY_APP_PATH` - Optional app to launch first

## Environment Variables

Configuration files support environment variable expansion:
- `${HOME}` - User home directory
- `${USER}` - Current username
- `${REPO_ROOT}` - Repository root directory (auto-set by wrapper scripts)
- `${SCRIPT_DIR}` - Directory containing the script (auto-set)

Example:
```bash
LOG_PATH="${REPO_ROOT}/logs/close-apps.log"
APP_LIST_PATH="${REPO_ROOT}/config/apps-to-close.txt"
```

## Validation

The system validates configuration on startup:
- Required files must exist
- Paths must be readable
- Schedule values must be in valid ranges
- Numeric values must be positive

Errors are logged to the error log file specified in the config.

## Documentation

For detailed configuration reference, see:
- [docs/CONFIGURATION.md](../docs/CONFIGURATION.md) - Complete option reference
- [docs/INSTALLATION.md](../docs/INSTALLATION.md) - Setup instructions
- [docs/TROUBLESHOOTING.md](../docs/TROUBLESHOOTING.md) - Common issues

## Examples

### Weekday-only closing (7 PM Mon-Fri)
```bash
SCHEDULE_HOUR=19
SCHEDULE_MINUTE=0
SCHEDULE_WEEKDAYS="1,2,3,4,5"
```

### Weekend morning opening (9 AM Sat-Sun)
```bash
SCHEDULE_HOUR=9
SCHEDULE_MINUTE=0
SCHEDULE_WEEKDAYS="0,6"
```

### Aggressive app closing (short timeout, more retries)
```bash
QUIT_TIMEOUT=1
RETRY_COUNT=3
CLOSE_DELAY=0.05
```

### Gentle app opening (longer delays)
```bash
STAGGER_DELAY=0.5
POST_LAUNCH_DELAY=3.0
SKIP_RUNNING=true
```
