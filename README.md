# macOS App Lifecycle Manager

Automated macOS application lifecycle management through scheduled closing and whitelist-based opening of applications.

## Overview

This project provides a modern, config-driven system for managing your Mac's application lifecycle:

- **Automated closing** - Close specified applications at scheduled times (e.g., 7:00 PM daily)
- **Whitelist opening** - Open selected applications at scheduled times (e.g., 8:00 AM daily)
- **Three-tier closing** - Handles standard apps, apps with generic process names, and stubborn Java apps
- **Fully configurable** - Paths, schedules, timing, and behavior all customizable
- **CLI tool** - Manual operations via `mac-app-lifecycle` command
- **launchd integration** - Native macOS scheduling via LaunchAgents

## Current Status: Phase 3 Complete ✅

This is an active migration from legacy AppleScript-based automation into a unified, portable system.

**Phase 1 - Foundation:** ✅ Complete
- ✅ Directory structure (bin/, scripts/, config/, launchd/, docs/)
- ✅ Configuration templates with all parameters documented
- ✅ App list file examples with three-tier closing strategy
- ✅ Shared library for logging and validation
- ✅ CLI stub with help text
- ✅ Comprehensive documentation

**Phase 2 - Close-Apps Implementation:** ✅ Complete
- ✅ AppleScript with three-tier closing logic (name/path/force)
- ✅ Shell wrapper with config loading and validation
- ✅ Structured logging with timestamps
- ✅ launchd plist template
- ✅ Tested successfully (closed 12 running apps)

**Phase 3 - Open-Apps Implementation:** ✅ Complete
- ✅ AppleScript with configurable delays and skip-running option
- ✅ Shell wrapper matching close-apps structure
- ✅ Optional primary app feature
- ✅ launchd plist template
- ✅ Tested successfully (launched 2 apps, skipped 3 running)

**Coming Next (Phase 4):**
- CLI tool implementation with subcommands (close, open, status, logs)
- Dry-run and verbose modes
- Installation validation

See [docs/MIGRATION_PLAN.md](docs/MIGRATION_PLAN.md) for the complete 7-phase roadmap.

## Quick Start (Phases 1-3 Complete)

```bash
# Clone repository
git clone <repository-url>
cd mac-app-lifecycle-manager

# Copy config templates (creates gitignored local configs)
cp config/close-apps.conf.example config/close-apps.conf
cp config/open-apps.conf.example config/open-apps.conf
cp config/apps-to-close.txt.example config/apps-to-close.txt
cp config/apps-to-open.txt.example config/apps-to-open.txt

# Create log directory
mkdir -p logs

# Edit configs and app lists
vim config/close-apps.conf
vim config/apps-to-close.txt
vim config/apps-to-open.txt

# Test scripts manually
./scripts/close-apps/close-apps.sh
./scripts/open-apps/open-apps.sh

# View logs
tail -f logs/close-apps.log
tail -f logs/open-apps.log
```

## Architecture

The system uses a proven three-component pattern:

1. **AppleScript (.applescript)** - Core macOS app control logic
2. **Shell wrapper (.sh)** - Parameter passing, logging, error handling
3. **launchd plist** - Scheduling via macOS LaunchAgents

**Why this pattern?** Direct `osascript` invocation from launchd is unreliable. Shell wrappers provide proper error handling, logging, and parameter passing.

## Three-Tier App Closing

Apps require different closing strategies:

### 1. Name-based (standard apps)
```applescript
tell application "ChatGPT" to quit
```
Used for most apps: Chrome, Slack, Messages, etc.

### 2. Path-based (generic process names)
```applescript
tell application "/Applications/Visual Studio Code.app" to quit
```
Required for: VS Code (appears as "Electron"), IntelliJ (appears as "idea"), Teams (appears as "MSTeams")

### 3. Force termination (stubborn apps)
```applescript
do shell script "pkill -f 'com.devexperts.tos.ui.user.thinkorswim'"
```
Required for: Java-based apps that ignore graceful quit commands

## Configuration

All paths, schedules, and behavior are configurable. Configuration files live in the repository:
- `config/close-apps.conf` (copy from `.example` template)
- `config/open-apps.conf` (copy from `.example` template)
- `config/apps-to-close.txt` (copy from `.example` template)
- `config/apps-to-open.txt` (copy from `.example` template)

These files are gitignored so your personal configuration stays local.

Key options:
- Schedule times (hour, minute, weekdays)
- Quit timeouts and retry counts
- Stagger delays between launches
- Log locations and verbosity
- App list file locations

See [docs/CONFIGURATION.md](docs/CONFIGURATION.md) for complete reference.

## Documentation

- **[CONFIGURATION.md](docs/CONFIGURATION.md)** - Complete configuration reference
- **[INSTALLATION.md](docs/INSTALLATION.md)** - Installation guide (stub, full version in Phase 5)
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Common issues (expanded during migration)
- **[MIGRATION_PLAN.md](docs/MIGRATION_PLAN.md)** - 7-phase migration roadmap
- **[config/README.md](config/README.md)** - Configuration system overview

## Project Structure

```
mac-app-lifecycle-manager/
├── bin/
│   └── mac-app-lifecycle              # CLI tool (stub in Phase 1, full in Phase 4)
├── scripts/
│   ├── close-apps/
│   │   ├── close-apps.applescript     # ✅ Phase 2 - Three-tier closing logic
│   │   └── close-apps.sh              # ✅ Phase 2 - Shell wrapper
│   ├── open-apps/
│   │   ├── open-apps.applescript      # ✅ Phase 3 - App opening with delays
│   │   └── open-apps.sh               # ✅ Phase 3 - Shell wrapper
│   └── lib/
│       └── common.sh                  # ✅ Shared logging & validation
├── config/
│   ├── *.conf.example                 # ✅ Configuration templates (versioned)
│   ├── *.conf                         # User configs (gitignored)
│   ├── apps-to-*.txt.example          # ✅ App list templates (versioned)
│   ├── apps-to-*.txt                  # User app lists (gitignored)
│   └── README.md                      # ✅ Config documentation
├── logs/                              # Log files (gitignored)
├── launchd/
│   ├── *.close.plist.template         # ✅ Phase 2 - Close-apps template
│   └── *.open.plist.template          # ✅ Phase 3 - Open-apps template
├── docs/
│   ├── CONFIGURATION.md               # ✅ Complete config reference
│   ├── INSTALLATION.md                # ✅ Stub (full version in Phase 5)
│   ├── TROUBLESHOOTING.md             # ✅ Stub (expanded during testing)
│   └── MIGRATION_PLAN.md              # ✅ 7-phase roadmap
├── install.sh                         # Coming in Phase 5
├── uninstall.sh                       # Coming in Phase 5
└── original-scripts-to-be-migrated/   # Legacy implementation (reference)
```

## System Requirements

- macOS 10.15 (Catalina) or later
- `osascript` (included with macOS)
- `launchctl` (included with macOS)
- Bash 3.2+ or zsh

**Permissions required:**
- Accessibility (for AppleScript to control apps)
- Automation (per-app approval)
- Full Disk Access (may be needed for Terminal.app)

## Features (Progress Toward v1.0.0)

- ✅ Config-driven paths and schedules
- ✅ Support for all three app-closing strategies
- ✅ Structured logging with timestamps
- ✅ Comprehensive error handling
- ✅ **Close-apps automation** (Phase 2 complete)
- ✅ **Open-apps automation** (Phase 3 complete)
- 🚧 Automated installation/uninstall (Phase 5)
- 🚧 CLI tool for manual operations (Phase 4)
- 🚧 launchd integration setup automation (Phase 5)
- 🚧 User documentation with examples (Phase 6-7)

## Contributing

This project is currently in active migration. See [docs/MIGRATION_PLAN.md](docs/MIGRATION_PLAN.md) for development roadmap.

## Original Implementation

The legacy scripts are preserved in `original-scripts-to-be-migrated/` for reference:
- `closeallapps/` - Original close-all-apps automation
- `openwhitelistapps/` - Original open-whitelist-apps automation

See `original-scripts-to-be-migrated/closeallapps/close_all_apps_readme.md` for detailed documentation of the original system.

## License

*To be determined*

## Support

For issues or questions during development:
1. Check [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
2. Review [docs/CONFIGURATION.md](docs/CONFIGURATION.md)
3. Consult original implementation in `original-scripts-to-be-migrated/`
