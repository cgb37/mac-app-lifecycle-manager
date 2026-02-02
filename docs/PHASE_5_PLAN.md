# Phase 5: Installation & Uninstall Scripts

## Overview
Automate setup and cleanup for the macOS App Lifecycle Manager.

## Goal
Create automated installation and uninstallation scripts that handle the complete setup and teardown of the system, including configuration, launchd agents, and documentation updates.

## Deliverables

### 1. Create `install.sh`
- **Interactive prompts for schedule times**: Ask user for close and open schedule times (HH:MM format)
- **Copy `.example` templates**: Create user config files from templates in `config/` (close-apps.conf, open-apps.conf, apps-to-close.txt, apps-to-open.txt)
- **Create log directory**: Ensure `logs/` exists
- **Generate plist files**: Use templates in `launchd/` to create personalized plist files with user's schedule
- **Copy plists to LaunchAgents**: Install to `~/Library/LaunchAgents/`
- **Set executable permissions**: On scripts and the CLI tool
- **Load launchd agents**: Use `launchctl load` to activate the agents
- **Validate installation**: Check that all files exist, agents are loaded, permissions are set
- **Instructions for permissions**: Display steps for Accessibility and Automation permissions

### 2. Create `uninstall.sh`
- **Unload launchd agents**: Use `launchctl unload` to deactivate
- **Remove plists**: Delete from `~/Library/LaunchAgents/`
- **Optionally remove config files**: Ask user if they want to remove `.conf` and `.txt` files from `config/`
- **Optionally remove logs**: Ask user if they want to remove log files from `logs/`
- **Confirmation prompts**: Especially for destructive actions (configs/logs)

### 3. Update Documentation
- **docs/INSTALLATION.md**: Step-by-step installation guide using the install.sh script
- **docs/TROUBLESHOOTING.md**: Common issues, permission setup, error scenarios

## Key Features
- **Non-destructive**: Backup existing configs if present
- **Validation**: Check macOS version (10.15+), required commands (osascript, launchctl)
- **Clear messages**: Success/error feedback with colored output
- **Idempotent**: Safe to run multiple times without issues

## Dependencies
- Builds on Phases 1-4: Config templates, launchd templates, scripts, CLI tool
- Requires: bash/zsh, standard macOS tools

## Testing
- Test on clean system: Fresh install, verify agents load, schedules work
- Test uninstall: Removes everything, optional cleanup works
- Edge cases: Existing configs, permission issues, invalid inputs

## Success Criteria
- Fresh installation succeeds without errors
- Uninstall removes all components cleanly
- Documentation accurately reflects the process
- Scripts handle edge cases gracefully

## Implementation Notes
- Use absolute paths where possible
- Validate user inputs (time formats, paths)
- Provide clear error messages with troubleshooting steps
- Make scripts executable and include shebang