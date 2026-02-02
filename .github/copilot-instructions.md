# macOS App Lifecycle Manager - AI Agent Instructions

## Project Overview

This project manages macOS application lifecycle through **automated scheduled closing** and **whitelist-based opening** of applications. The goal is to migrate legacy AppleScript-based automation into a modern, maintainable system.

## Architecture: Three-Component Pattern

All automation follows this proven structure from the original scripts:

1. **AppleScript (.scpt)** - Core automation logic for macOS app control
2. **Shell wrapper (.sh)** - Parameter passing, logging, error handling
3. **launchd plist** - Scheduling via macOS LaunchAgents

**Why this pattern?** Direct osascript invocation from launchd is unreliable. Shell wrappers provide better error handling and logging. See [original-scripts-to-be-migrated/closeallapps/close_all_apps_readme.md](original-scripts-to-be-migrated/closeallapps/close_all_apps_readme.md) for detailed rationale.

## Critical App Closing Logic

Apps fall into three categories requiring different handling:

### 1. Name-based closing (standard apps)
```applescript
tell application "ChatGPT" to quit
```
Used for: ChatGPT, Chrome, Slack, Messages, etc.

### 2. Path-based closing (problematic process names)
```applescript
tell application "/Applications/Visual Studio Code.app" to quit
```
**Required for:** VS Code (appears as "Electron"), IntelliJ (appears as "idea"), Teams (appears as "MSTeams"), DataGrip, Sublime Text

**Why?** These apps have generic/non-standard process names in System Events.

### 3. Force termination (stubborn apps)
```applescript
do shell script "pkill -f 'com.devexperts.tos.ui.user.thinkorswim'"
```
**Required for:** Java-based apps like thinkorswim that ignore graceful quit commands.

See [CloseAllApps_source.applescript](original-scripts-to-be-migrated/closeallapps/CloseAllApps_source.applescript) for implementation examples.

## File Paths & Hardcoded Locations

Original scripts expect installation at:
```
~/.oh-my-zsh/custom/scripts/closeallapps/
~/.oh-my-zsh/custom/scripts/openwhitelistapps/
```

**Migration strategy:**
- Use `$HOME` or `~` for user home directory (don't hardcode `/Users/username`)
- Support installation in any directory via relative paths
- Config file should specify all paths (scripts, logs, whitelists)
- Consider XDG Base Directory pattern: `~/.config/mac-app-lifecycle/` for configs, `~/.local/share/mac-app-lifecycle/` for data
- Default log location: `/tmp/` (system-managed cleanup) or `~/Library/Logs/mac-app-lifecycle/`

## Naming Convention Normalization

Current inconsistencies between close/open scripts:
- **Labels:** `com.user.closeallapps` vs `com.user.openwhitelistapps`
- **Log files:** `/tmp/closeapps.log` vs `/tmp/openapps.log`
- **Scripts:** `run_close_apps.sh` vs `run_open_apps.sh`

**Target convention:**
- Use consistent prefix: `mac-app-lifecycle-`
- Labels: `com.user.mac-app-lifecycle.close`, `com.user.mac-app-lifecycle.open`
- Scripts: `close-apps.sh`, `open-apps.sh` (or keep `run_` prefix consistently)
- Logs: `mac-app-lifecycle-close.log`, `mac-app-lifecycle-open.log`
- Config: Single unified `config.conf` or separate `close-apps.conf`, `open-apps.conf`

## Whitelist App Opening

Opens apps from a text file ([whitelist.txt](original-scripts-to-be-migrated/openwhitelistapps/whitelist.txt)) containing full paths:
```
/Applications/GitKraken.app
/Applications/Google Chrome.app
```

Configuration-driven via [openwhitelistapps.conf](original-scripts-to-be-migrated/openwhitelistapps/openwhitelistapps.conf):
- `WHITELIST_PATH` - App list file
- `PRIMARY_APP_PATH` - Optional primary app (opened first)
- `STAGGER_DELAY` - Time between launches (default: 0.2s)
- `POST_LAUNCH_DELAY` - Wait after all apps open (default: 1.5s)

## launchd Integration

Launch agents go in `~/Library/LaunchAgents/` and use calendar intervals:
```xml
<key>StartCalendarInterval</key>
<dict>
    <key>Hour</key>
    <integer>19</integer>  <!-- 24-hour format -->
    <key>Minute</key>
    <integer>0</integer>
</dict>
```

**Testing without waiting:** `launchctl start com.user.closeallapps`

**Logs:** `/tmp/closeapps.log`, `/tmp/openapps.log` (configurable via .conf files)

## Migration Goals

This is a **pre-migration codebase**. All functional code lives in `original-scripts-to-be-migrated/`. The migration aims to:

### Unification & Portability
- **Unified repository structure** - Consolidate close/open scripts into coherent, maintainable structure
- **Config-driven everything** - No hardcoded paths (currently `~/.oh-my-zsh/custom/scripts/...`)
- **Usable by any Mac user** - Eliminate user-specific assumptions
- **Consistent naming conventions** - Normalize between close/open implementations
- **Proper error handling** - Graceful failures with clear user feedback
- **Structured logging** - Consistent log format across all components
- **Installation automation** - Script to set up entire system

### Technical Requirements
1. Preserve the three-component architecture (AppleScript + shell + launchd)
2. Support all three app-closing strategies (name/path/force)
3. Make paths configurable via centralized config file
4. Normalize approach between open and close scripts
5. Add user feedback via console for manual runs
6. Keep launchd/launchctl as deployment target (no GUI apps yet)

## Key Files to Reference

- [close_all_apps_readme.md](original-scripts-to-be-migrated/closeallapps/close_all_apps_readme.md) - Comprehensive documentation of close-all-apps system
- [CloseAllApps_source.applescript](original-scripts-to-be-migrated/closeallapps/CloseAllApps_source.applescript) - Three-tier closing logic
- [openwhitelistapps.conf](original-scripts-to-be-migrated/openwhitelistapps/openwhitelistapps.conf) - Configuration pattern to follow
- [run_open_apps.sh](original-scripts-to-be-migrated/openwhitelistapps/run_open_apps.sh) - Shell wrapper best practices

## Common Pitfalls

1. **Don't use process names for all apps** - Some appear with generic names like "Electron" or "java"
2. **Don't skip the shell wrapper** - Direct osascript from launchd is unreliable
3. **Don't forget timeout handling** - Apps can hang on quit (use `with timeout of 3 seconds`)
4. **Test with actual launchctl** - Direct script execution may behave differently than scheduled runs

## System Requirements & Gotchas

### macOS Permissions
- **Accessibility permissions** - Required for AppleScript to control apps
- **Full Disk Access** - May be needed for certain apps (Terminal.app, script runners)
- **Automation permissions** - Per-app approval for controlling other apps (System Settings → Privacy & Security → Automation)

### Installation Script Must Handle
- Creating `~/Library/LaunchAgents/` if missing
- Setting executable permissions on shell scripts
- Loading/unloading launchd agents properly
- Validating config file paths exist
- Checking for required permissions

### Testing & Validation
- **Don't test during development** - Focus on getting core functionality working first
- **Manual validation** - Run scripts directly with `osascript` and shell scripts
- **launchctl testing** - Use `launchctl start` to test without waiting for schedule
- **Log inspection** - Check `/tmp/closeapps.log` and `/tmp/openapps.log` for issues
- **Automated tests** - Will be added after migration is complete and stable

## Known Issues (Document During Migration)

As issues are discovered during migration, document them here with:
- Problem description
- Root cause
- Solution or workaround
- Files affected

## IMPORTANT: Changelog Management

**DO NOT manually edit CHANGELOG.md** - This file is managed by automated release tooling (`release-it` with `@release-it/conventional-changelog`). 

- Changes are automatically generated from conventional commit messages
- Manual edits will be overwritten on next release
- Document new features/fixes in commit messages using [Conventional Commits](https://conventionalcommits.org) format
- For documentation of changes, update relevant docs in `docs/` directory instead
