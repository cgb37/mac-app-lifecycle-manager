# Commands Reference

This document provides a comprehensive reference for all commands available in the macOS App Lifecycle Manager.

## Quick Start

```bash
# Install the system
./install.sh

# Check status
./bin/mac-app-lifecycle status

# Close apps manually
./bin/mac-app-lifecycle close --now

# View logs
./bin/mac-app-lifecycle logs close
```

## CLI Tool Commands

The main `mac-app-lifecycle` command provides user-friendly operations:

### Core Operations
```bash
# Close configured applications
./bin/mac-app-lifecycle close --now
./bin/mac-app-lifecycle close --dry-run    # Preview what would happen

# Open whitelisted applications
./bin/mac-app-lifecycle open --now
./bin/mac-app-lifecycle open --verbose      # Show detailed output
```

### Status & Monitoring
```bash
# Check launchd agent status
./bin/mac-app-lifecycle status

# View plist configurations
./bin/mac-app-lifecycle plist close
./bin/mac-app-lifecycle plist open

# View logs
./bin/mac-app-lifecycle logs close
./bin/mac-app-lifecycle logs open
```

### Information
```bash
# Show help
./bin/mac-app-lifecycle help
./bin/mac-app-lifecycle --help

# Show version
./bin/mac-app-lifecycle version
./bin/mac-app-lifecycle --version
```

## Installation & Setup

### Automated Installation
```bash
# Install with interactive prompts
./install.sh

# Install with dry-run (preview)
./install.sh --dry-run

# Install with verbose output
./install.sh --verbose
```

### Uninstallation
```bash
# Remove the system
./uninstall.sh
```

## Development & Testing

### npm Scripts
```bash
# Run all tests
npm test
npm run test:all

# Test specific components
npm run test:cli              # CLI command tests
npm run test:cli-options      # CLI option parsing tests
npm run test:cli-integration  # CLI integration tests
npm run test:open-apps        # Open-apps script tests
npm run test:close-apps       # Close-apps script tests
npm run test:release-it       # Release tooling tests

# Development operations
npm run open-apps             # Run open-apps script directly
npm run close-apps            # Run close-apps script directly

# Release management
npm run release               # Create new release
npm run release:major         # Major version bump
npm run release:minor         # Minor version bump
npm run release:patch         # Patch version bump
npm run release:set           # Set specific version
```

### Direct Script Execution
```bash
# Test scripts directly
./scripts/close-apps/close-apps.sh
./scripts/open-apps/open-apps.sh

# With dry-run mode
DRY_RUN=1 ./scripts/close-apps/close-apps.sh
DRY_RUN=1 ./scripts/open-apps/open-apps.sh

# With verbose logging
LOG_LEVEL=DEBUG ./scripts/close-apps/close-apps.sh
```

## System Integration

### launchd Management
```bash
# Check if agents are loaded
launchctl list | grep mac-app-lifecycle

# Check specific agent status
launchctl list com.user.mac-app-lifecycle.close
launchctl list com.user.mac-app-lifecycle.open

# View detailed agent information (macOS 11+)
launchctl print gui/$(id -u)/com.user.mac-app-lifecycle.close
launchctl print gui/$(id -u)/com.user.mac-app-lifecycle.open

# Manual load/unload (normally handled by install.sh/uninstall.sh)
launchctl load ~/Library/LaunchAgents/com.user.mac-app-lifecycle.close.plist
launchctl unload ~/Library/LaunchAgents/com.user.mac-app-lifecycle.close.plist
```

### File System Checks
```bash
# Check if plist files exist
ls -la ~/Library/LaunchAgents/com.user.mac-app-lifecycle.*.plist

# Check configuration files
ls -la config/

# Check log files
ls -la logs/

# Check script permissions
ls -la bin/ scripts/**/*.sh
```

## Troubleshooting Commands

### Log Inspection
```bash
# View recent close-app logs
tail -f logs/close-apps.log
tail -20 logs/close-apps.log

# View recent open-app logs
tail -f logs/open-apps.log
tail -20 logs/open-apps.log

# View error logs
tail -f logs/close-apps.err
tail -f logs/open-apps.err
```

### Configuration Validation
```bash
# Check config file syntax
cat config/close-apps.conf
cat config/open-apps.conf

# Check app lists
cat config/apps-to-close.txt
cat config/apps-to-open.txt
```

### Permission Checks
```bash
# Check script executability
ls -la bin/mac-app-lifecycle
ls -la scripts/**/*.sh

# Check Accessibility permissions (manual)
# System Settings → Privacy & Security → Accessibility

# Check Automation permissions (manual)
# System Settings → Privacy & Security → Automation
```

## Command Categories

### User Operations (Most Common)
- `./bin/mac-app-lifecycle close --now`
- `./bin/mac-app-lifecycle open --now`
- `./bin/mac-app-lifecycle status`
- `./bin/mac-app-lifecycle logs close`

### Administrative
- `./install.sh`
- `./uninstall.sh`
- `./bin/mac-app-lifecycle plist close`

### Development
- `npm run test:all`
- `npm run test:cli`
- `./scripts/close-apps/close-apps.sh`

### System-Level
- `launchctl list com.user.mac-app-lifecycle.close`
- `ls -la ~/Library/LaunchAgents/`

## Common Workflows

### First-Time Setup
```bash
./install.sh
./bin/mac-app-lifecycle status
./bin/mac-app-lifecycle close --now
```

### Daily Usage
```bash
./bin/mac-app-lifecycle status
./bin/mac-app-lifecycle logs close
```

### Troubleshooting Issues
```bash
./bin/mac-app-lifecycle status
./bin/mac-app-lifecycle plist close
tail -20 logs/close-apps.log
launchctl list com.user.mac-app-lifecycle.close
```

### Development Testing
```bash
npm run test:all
./bin/mac-app-lifecycle close --dry-run
DRY_RUN=1 ./scripts/close-apps/close-apps.sh
```

## Exit Codes

The CLI tool uses these exit codes:

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Installation validation failed |
| 3 | Configuration validation failed |
| 4 | Command execution failed |

## Notes

- All paths are relative to the repository root
- CLI commands validate installation before running
- Use `--dry-run` to preview operations
- Use `--verbose` for detailed output
- Scripts automatically create log directories as needed
- launchd agents are managed by install.sh/uninstall.sh

## See Also

- [Installation Guide](INSTALLATION.md) - Setup instructions
- [Configuration Reference](CONFIGURATION.md) - Config options
- [Troubleshooting Guide](TROUBLESHOOTING.md) - Common issues
- [Migration Plan](MIGRATION_PLAN.md) - Development roadmap

---

**Note**: This document is the comprehensive commands reference. For specific guides, see the documentation links above.</content>
<parameter name="filePath">/Users/charlesbrownroberts/Code/CGB/mac-app-lifecycle-manager/docs/COMMANDS.md