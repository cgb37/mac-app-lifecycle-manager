# Configuration Reference

Complete reference for all configuration options in the macOS App Lifecycle Manager.

## Configuration Files

Configuration files are plain text shell scripts that set environment variables. They are sourced by the wrapper scripts and support shell variable expansion.

**Default locations (in repository):**
- `config/close-apps.conf`
- `config/open-apps.conf`

**Templates (version controlled):**
- `config/close-apps.conf.example`
- `config/open-apps.conf.example`

---

## Common Options (Both Configs)

### Logging

#### LOG_PATH
- **Description:** Path to the main log file
- **Type:** String (file path)
- **Default:** 
  - Close: `${REPO_ROOT}/logs/close-apps.log`
  - Open: `${REPO_ROOT}/logs/open-apps.log`
- **Example:** `LOG_PATH="${REPO_ROOT}/logs/my-close.log"`

#### ERR_LOG_PATH
- **Description:** Path to the error log file
- **Type:** String (file path)
- **Default:**
  - Close: `${REPO_ROOT}/logs/close-apps.err`
  - Open: `${REPO_ROOT}/logs/open-apps.err`
- **Example:** `ERR_LOG_PATH="${REPO_ROOT}/logs/my-errors.err"`

#### LOG_LEVEL
- **Description:** Verbosity of logging
- **Type:** String enum
- **Valid values:** `DEBUG`, `INFO`, `WARN`, `ERROR`
- **Default:** `INFO`
- **Example:** `LOG_LEVEL="DEBUG"`

### Scheduling

#### SCHEDULE_HOUR
- **Description:** Hour to run the automation (24-hour format)
- **Type:** Integer
- **Range:** 0-23 (0 = midnight, 12 = noon, 23 = 11 PM)
- **Default:**
  - Close: `19` (7:00 PM)
  - Open: `8` (8:00 AM)
- **Example:** `SCHEDULE_HOUR=9`

#### SCHEDULE_MINUTE
- **Description:** Minute to run the automation
- **Type:** Integer
- **Range:** 0-59
- **Default:** `0`
- **Example:** `SCHEDULE_MINUTE=30`

#### SCHEDULE_WEEKDAYS
- **Description:** Comma-separated list of weekdays to run (optional)
- **Type:** String (comma-separated integers)
- **Range:** 0-6 (0 = Sunday, 1 = Monday, ..., 6 = Saturday)
- **Default:** `""` (empty = every day)
- **Examples:**
  - Weekdays only: `SCHEDULE_WEEKDAYS="1,2,3,4,5"`
  - Weekends only: `SCHEDULE_WEEKDAYS="0,6"`
  - Mon/Wed/Fri: `SCHEDULE_WEEKDAYS="1,3,5"`

---

## close-apps.conf Options

### Paths

#### APP_LIST_PATH
- **Description:** Path to file containing list of apps to close
- **Type:** String (file path)
- **Default:** `${REPO_ROOT}/config/apps-to-close.txt`
- **Example:** `APP_LIST_PATH="${REPO_ROOT}/config/my-apps.txt"`
- **See also:** [App List Format](#app-list-format)

#### APPLESCRIPT_PATH
- **Description:** Path to the AppleScript that performs the closing
- **Type:** String (file path)
- **Default:** `${SCRIPT_DIR}/close-apps.applescript` (auto-detected)
- **Example:** `APPLESCRIPT_PATH="/custom/path/close-apps.applescript"`
- **Note:** Usually doesn't need to be changed

### Behavior

#### QUIT_TIMEOUT
- **Description:** Seconds to wait for graceful app quit
- **Type:** Integer or float
- **Range:** > 0
- **Default:** `3`
- **Example:** `QUIT_TIMEOUT=5`
- **Note:** Apps that don't quit within this timeout will be retried

#### CLOSE_DELAY
- **Description:** Seconds to pause between closing each app
- **Type:** Float
- **Range:** ≥ 0
- **Default:** `0.1`
- **Example:** `CLOSE_DELAY=0.2`
- **Note:** Useful if rapid closing causes system issues

#### RETRY_COUNT
- **Description:** Number of retry attempts before force quitting
- **Type:** Integer
- **Range:** ≥ 0
- **Default:** `2`
- **Example:** `RETRY_COUNT=3`
- **Note:** Set to `0` to never force quit

---

## open-apps.conf Options

### Paths

#### WHITELIST_PATH
- **Description:** Path to file containing list of apps to open
- **Type:** String (file path)
- **Default:** `${REPO_ROOT}/config/apps-to-open.txt`
- **Example:** `WHITELIST_PATH="${REPO_ROOT}/config/my-whitelist.txt"`
- **See also:** [Whitelist Format](#whitelist-format)

#### PRIMARY_APP_PATH
- **Description:** Optional app to launch first (before whitelist apps)
- **Type:** String (file path to .app bundle)
- **Default:** `""` (empty = disabled)
- **Example:** `PRIMARY_APP_PATH="/Applications/Google Chrome.app"`
- **Note:** Leave empty to disable this feature

#### APPLESCRIPT_PATH
- **Description:** Path to the AppleScript that performs the opening
- **Type:** String (file path)
- **Default:** `${SCRIPT_DIR}/open-apps.applescript` (auto-detected)
- **Example:** `APPLESCRIPT_PATH="/custom/path/open-apps.applescript"`
- **Note:** Usually doesn't need to be changed

### Behavior

#### STAGGER_DELAY
- **Description:** Seconds to pause between launching each app
- **Type:** Float
- **Range:** ≥ 0
- **Default:** `0.2`
- **Example:** `STAGGER_DELAY=0.5`
- **Note:** Prevents overwhelming the system with simultaneous launches

#### POST_LAUNCH_DELAY
- **Description:** Seconds to wait after all apps have been launched
- **Type:** Float
- **Range:** ≥ 0
- **Default:** `1.5`
- **Example:** `POST_LAUNCH_DELAY=3.0`
- **Note:** Allows apps to initialize before script exits

#### SKIP_RUNNING
- **Description:** Skip apps that are already running
- **Type:** Boolean (`true` or `false`)
- **Default:** `true`
- **Example:** `SKIP_RUNNING=false`
- **Note:** Set to `false` to relaunch apps even if already running

---

## File Formats

### App List Format (close-apps)

The `apps-to-close.txt` file supports three formats for different app types:

```bash
# 1. Standard apps (close by name)
ChatGPT
Google Chrome
Slack

# 2. Apps with problematic process names (close by path)
PATH:/Applications/Visual Studio Code.app
PATH:/Applications/IntelliJ IDEA Ultimate.app

# 3. Stubborn apps (force quit by bundle ID pattern)
FORCE:com.devexperts.tos.ui.user.thinkorswim
```

**Rules:**
- One app per line
- Lines starting with `#` are comments
- Blank lines are ignored
- No quotes needed around names or paths

**When to use each format:**
- **Name:** Most apps (Chrome, Slack, Messages, etc.)
- **Path:** Apps with generic process names (VS Code → "Electron", IntelliJ → "idea")
- **Force:** Java apps or apps that ignore graceful quit commands

### Whitelist Format (open-apps)

The `apps-to-open.txt` file contains full paths to .app bundles:

```bash
# One app path per line
/Applications/Google Chrome.app
/Applications/Slack.app
/Applications/Visual Studio Code.app

# Spaces in paths are fine (no quotes needed)
/Applications/Microsoft Teams.app

# User-specific apps
/Users/username/Applications/Custom App.app
```

**Rules:**
- One full path per line
- Must be absolute paths
- Lines starting with `#` are comments
- Blank lines are ignored
- Apps launch in order listed (unless PRIMARY_APP_PATH is set)

---

## Environment Variables

Configuration files are shell scripts and support variable expansion:

```bash
# User home directory
LOG_PATH="${HOME}/custom-logs/close-apps.log"

# Current username
APP_LIST_PATH="/Users/${USER}/my-apps.txt"

# Repository root (auto-set by wrapper scripts)
LOG_PATH="${REPO_ROOT}/logs/close-apps.log"
APP_LIST_PATH="${REPO_ROOT}/config/apps-to-close.txt"

# Script directory (auto-set by wrapper script)
APPLESCRIPT_PATH="${SCRIPT_DIR}/close-apps.applescript"
```

---

## Validation

On startup, the system validates:

- **Required files exist:** APP_LIST_PATH, WHITELIST_PATH, APPLESCRIPT_PATH
- **Files are readable:** Config files, app lists, scripts
- **Numeric values:** SCHEDULE_HOUR (0-23), SCHEDULE_MINUTE (0-59), timeouts (> 0)
- **Commands available:** `osascript`, `launchctl`

Validation errors are logged and the script exits with code 2.

---

## Examples

### Example 1: Weekday Work Schedule

Close apps at 7 PM on weekdays only:
```bash
# close-apps.conf
SCHEDULE_HOUR=19
SCHEDULE_MINUTE=0
SCHEDULE_WEEKDAYS="1,2,3,4,5"
```

Open apps at 8 AM on weekdays only:
```bash
# open-apps.conf
SCHEDULE_HOUR=8
SCHEDULE_MINUTE=0
SCHEDULE_WEEKDAYS="1,2,3,4,5"
```

### Example 2: Aggressive Closing

Quick timeout with multiple retries:
```bash
# close-apps.conf
QUIT_TIMEOUT=1
RETRY_COUNT=5
CLOSE_DELAY=0.05
```

### Example 3: Gentle Opening

Slow, deliberate app launching:
```bash
# open-apps.conf
STAGGER_DELAY=1.0
POST_LAUNCH_DELAY=5.0
SKIP_RUNNING=true
PRIMARY_APP_PATH="/Applications/Google Chrome.app"
```

### Example 4: Custom Log Location

Store logs outside the repository:
```bash
# close-apps.conf
LOG_PATH="${HOME}/Documents/logs/close-apps.log"
ERR_LOG_PATH="${HOME}/Documents/logs/close-apps.err"
LOG_LEVEL="DEBUG"
```

### Example 5: Weekend Only

Run only on Saturday and Sunday:
```bash
# Both configs
SCHEDULE_WEEKDAYS="0,6"
```

---

## Troubleshooting

### Configuration not loading
- Verify file exists at `config/close-apps.conf` or `config/open-apps.conf`
- Check file permissions (must be readable)
- Review error log for parsing errors
- Ensure you copied from `.example` templates

### Schedule not triggering
- Verify launchd plist is loaded: `launchctl list | grep mac-app-lifecycle`
- Check SCHEDULE_HOUR and SCHEDULE_MINUTE values
- If using SCHEDULE_WEEKDAYS, verify day numbers (0 = Sunday)

### Apps not closing/opening
- Verify APP_LIST_PATH / WHITELIST_PATH points to correct file
- Check app list file format (no quotes, correct syntax)
- Review logs for specific error messages
- Test AppleScript directly: `osascript scripts/close-apps/close-apps.applescript`

For more troubleshooting, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

---

## See Also

- [Installation Guide](INSTALLATION.md) - Setup instructions
- [Troubleshooting Guide](TROUBLESHOOTING.md) - Common issues
- [Migration Plan](MIGRATION_PLAN.md) - Development roadmap
- [config/README.md](../config/README.md) - Config system overview
