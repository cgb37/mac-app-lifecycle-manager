# Installation Guide

> **Note:** This is a stub document for Phase 1. Full installation instructions will be added in Phase 5.

## Quick Start

The installation process will be automated via `install.sh` script in Phase 5.

## Manual Setup (For Development)

For Phase 1-4 development and testing:

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd mac-app-lifecycle-manager
   ```

2. **Copy config templates:**
   ```bash
   cd mac-app-lifecycle-manager
   cp config/close-apps.conf.example config/close-apps.conf
   cp config/open-apps.conf.example config/open-apps.conf
   ```

3. **Copy app list templates:**
   ```bash
   cp config/apps-to-close.txt.example config/apps-to-close.txt
   cp config/apps-to-open.txt.example config/apps-to-open.txt
   ```

4. **Edit configuration files:**
   ```bash
   # Customize schedules, paths, and behavior
   vim config/close-apps.conf
   vim config/open-apps.conf
   
   # Customize app lists
   vim config/apps-to-close.txt
   vim config/apps-to-open.txt
   ```

5. **Create log directory:**
   ```bash
   mkdir -p logs
   ```

## System Requirements

- macOS 10.15 (Catalina) or later
- `osascript` (included with macOS)
- `launchctl` (included with macOS)
- Bash 3.2+ or zsh

## Required Permissions

macOS will prompt for these permissions the first time you run the scripts:

- **Accessibility** - Required for AppleScript to control apps
- **Automation** - Per-app approval for controlling other apps
- **Full Disk Access** - May be needed for Terminal.app or script runner

Configure in: System Settings → Privacy & Security → Accessibility / Automation

## What's Coming in Phase 5

The full installation script (`install.sh`) will:
- ✅ Interactive setup with prompts for schedules
- ✅ Automatic config file generation
- ✅ launchd plist generation from templates
- ✅ Permission verification
- ✅ Installation validation
- ✅ Automatic loading of launchd agents

## Documentation

- [Configuration Reference](CONFIGURATION.md) - All config options
- [Troubleshooting Guide](TROUBLESHOOTING.md) - Common issues
- [Migration Plan](MIGRATION_PLAN.md) - Development roadmap

## Support

For issues during development, see:
- Phase 1 implementation details in `docs/MIGRATION_PLAN.md`
- Configuration examples in `config/README.md`
- Original implementation in `original-scripts-to-be-migrated/`
