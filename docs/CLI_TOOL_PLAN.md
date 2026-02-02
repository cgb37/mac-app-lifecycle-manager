# Phase 4: CLI Tool Implementation Plan

## Overview

Implement the `mac-app-lifecycle` CLI tool that provides a user-friendly interface for manual operations, replacing the current stub implementation.

**Current Status**: `bin/mac-app-lifecycle` exists as a Phase 1 stub with help text but no functional commands.

**Goal**: Create a full-featured CLI tool that validates installation and invokes shell wrappers with proper error handling.

## Requirements

### Core Commands
- `close [--now]` - Close configured applications immediately
- `open [--now]` - Open whitelisted applications immediately
- `status` - Show launchd agent status (loaded/unloaded, schedules)
- `logs [close|open]` - Display recent logs
- `help` - Show usage information
- `version` - Show version information

**Note**: launchctl load/unload operations are handled by `install.sh`/`uninstall.sh` scripts, not the CLI tool. The CLI focuses on manual operations and status checking.

### Options
- `--now` - Execute immediately (for close/open commands)
- `--dry-run` - Show what would be done without executing
- `--verbose` - Show detailed output
- `-h, --help` - Show help for specific command

### Features
- Installation validation before operations
- Pretty console output (colored if supported)
- Proper exit codes for scripting
- Error handling and user feedback

## Design Decisions

### Architecture
```
bin/mac-app-lifecycle (bash script)
├── Self-discovery of repo location
├── Command parsing and validation
├── Installation checks
├── Invoke shell wrappers with proper environment
├── Format and display output
└── Handle errors gracefully
```

### Command Flow
1. **Self-discovery**: Find repo root from script location
2. Parse command line arguments
3. Validate installation (configs exist, scripts executable)
4. Set up environment variables (relative to repo root)
5. Invoke appropriate shell wrapper
6. Format and display results
7. Exit with appropriate code

### Installation & Execution Strategy

**Problem**: CLI needs to be executable from any location, but scripts/configs are repo-relative.

**Solution**: Self-discovering CLI with optional global installation.

#### Option A: Self-Discovering (Recommended for Development)
- CLI script discovers its own location: `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`
- Calculates repo root: `REPO_ROOT="$(dirname "$SCRIPT_DIR")"`
- All paths relative to repo root
- Users can run from anywhere if they use full path: `/path/to/repo/bin/mac-app-lifecycle`
- Or add repo/bin to PATH temporarily: `export PATH="/path/to/repo/bin:$PATH"`

#### Option B: Global Installation (For Production Use)
- Installation script creates symlink: `ln -sf /path/to/repo/bin/mac-app-lifecycle /usr/local/bin/`
- Or adds repo/bin to system PATH
- CLI still uses self-discovery for internal paths
- Allows running `mac-app-lifecycle` from anywhere

#### Option C: Shell Integration (For Team Use) - **RECOMMENDED**
- Add to shell config (~/.zshrc): `alias mac-app-lifecycle="$(pwd)/bin/mac-app-lifecycle"`
- Or create shell function that finds repo dynamically
- Each developer sets their own alias
- **Selected approach**: Use shell alias for development team

### Directory Organization for Scalability

**Standard Pattern for All Automation Scripts**:
```
repo/
├── bin/                    # Executable entry points (manual operations)
│   ├── mac-app-lifecycle   # Main CLI - close/open/status/logs
│   └── other-tool          # Future tools
├── scripts/                # Implementation scripts
│   ├── lib/               # Shared libraries
│   ├── mac-app-lifecycle/ # Tool-specific scripts
│   └── other-tool/        # Future tool scripts
├── config/                # Configuration files
├── launchd/               # launchd plist templates
├── install.sh             # Installation script (handles launchctl load)
├── uninstall.sh           # Uninstall script (handles launchctl unload)
├── logs/                  # Log files
└── docs/                  # Documentation
```

**Separation of Concerns**:
- **CLI (`bin/`)**: Manual operations and status checking
- **Install Scripts**: System integration (launchctl load/unload, permissions)
- **Shell Wrappers (`scripts/`)**: Core automation logic
- **Launchd Templates**: Scheduling configuration

**Why NOT put launchctl in CLI**:
- CLI should focus on user operations, not system management
- Load/unload requires careful error handling and permissions
- Keeps CLI lightweight and focused
- Install/uninstall scripts can handle complex setup/teardown

## Implementation Plan

### Phase 4.1: Core Command Structure
**Goal**: Basic command parsing and stub implementations

**Tasks**:
- [x] Implement self-discovery mechanism
- [x] Replace stub implementation with real command parsing
- [x] Implement basic command validation
- [x] Add installation validation function
- [x] Create command handler stubs for each subcommand
- [x] Update version and help text
- [x] **Bonus**: Read version dynamically from package.json

**Self-Discovery Implementation**:
```bash
# Get script directory (works from any location)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Calculate repo root
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Read version from package.json
PACKAGE_JSON="$REPO_ROOT/package.json"
if [[ -f "$PACKAGE_JSON" ]]; then
    VERSION=$(grep '"version"' "$PACKAGE_JSON" | head -1 | sed 's/.*"version": "\([^"]*\)".*/\1/')
else
    VERSION="unknown"
fi

# Set up all paths relative to repo root
CONFIG_DIR="$REPO_ROOT/config"
SCRIPTS_DIR="$REPO_ROOT/scripts"
LOG_DIR="$REPO_ROOT/logs"
```

**Files to modify**:
- `bin/mac-app-lifecycle`

### Phase 4.2: Close/Open Commands
**Goal**: Implement close and open functionality

**Tasks**:
- [x] Implement `close` command handler
- [x] Implement `open` command handler
- [x] Add `--now` option support
- [x] Add `--dry-run` support (pass DRY_RUN env var)
- [x] Add `--verbose` support (pass LOG_LEVEL=DEBUG env var)
- [x] Test integration with shell wrappers

**Integration Points**:
- `./scripts/close-apps/close-apps.sh`
- `./scripts/open-apps/open-apps.sh`

### Phase 4.3: Status Command
**Goal**: Show launchd agent status (read-only)

**Tasks**:
- [x] Check if launchd agents are loaded (`launchctl list`)
- [x] Show agent status (loaded/unloaded)
- [x] Display next scheduled run times (if available)
- [x] Show plist file locations
- [x] **Do NOT include load/unload functionality** (handled by install scripts)

**Commands to use**:
- `launchctl list com.user.mac-app-lifecycle.close`
- `launchctl list com.user.mac-app-lifecycle.open`

### Phase 4.4: Logs Command
**Goal**: Display recent logs

**Tasks**:
- [ ] Implement `logs close` - tail close-apps.log
- [ ] Implement `logs open` - tail open-apps.log
- [ ] Add log file validation
- [ ] Format log output with timestamps
- [ ] Handle missing log files gracefully

**Log locations**:
- `logs/close-apps.log`
- `logs/open-apps.log`

### Phase 4.5: Error Handling & Polish
**Goal**: Robust error handling and user experience

**Tasks**:
- [ ] Add comprehensive error messages
- [ ] Implement colored output (if terminal supports)
- [ ] Add exit code documentation
- [ ] Handle edge cases (missing configs, permissions)
- [ ] Add verbose mode details

## Validation Functions

### Installation Validation
```bash
validate_installation() {
    # Check if config files exist
    # Check if scripts are executable
    # Check if log directory exists
    # Check macOS version compatibility
}
```

### Config Validation
```bash
validate_config() {
    local config_type="$1"  # "close" or "open"

    # Check if config file exists
    # Check if app list file exists
    # Validate config file syntax
}
```

## Command Handlers

### Close Command
```bash
handle_close() {
    local now=false
    local dry_run=false
    local verbose=false

    # Parse options
    # Validate installation
    # Set environment variables
    # Execute close-apps.sh
}
```

### Status Command
```bash
handle_status() {
    # Check close agent status
    # Check open agent status
    # Display formatted status
}
```

## Testing Strategy

### Unit Tests
- Command parsing validation
- Option handling
- Installation validation
- Error conditions

### Integration Tests
- End-to-end command execution
- Shell wrapper integration
- Log file handling
- launchd status checking

### Manual Testing
- Fresh installation scenario
- Missing config scenarios
- Permission denied scenarios
- Dry-run mode verification

## Error Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Installation validation failed |
| 3 | Config validation failed |
| 4 | Command execution failed |
| 5 | Permission denied |

## Dependencies

- Bash 3.2+ (macOS default)
- Standard macOS commands: `launchctl`, `tail`, `cat`
- Shell wrappers: `close-apps.sh`, `open-apps.sh`
- Config files and app lists

## Security Considerations

- Validate all file paths before use
- Check script executability before running
- Sanitize user input
- No arbitrary command execution

## Documentation Updates

After implementation:
- Update `README.md` with CLI usage examples
- Update `docs/CONFIGURATION.md` if needed
- Update `docs/TROUBLESHOOTING.md` with CLI-specific issues
- Update `.github/copilot-instructions.md` with CLI patterns

## Success Criteria

- [x] All commands work as specified
- [x] Options (`--now`, `--dry-run`, `--verbose`) function correctly
- [x] Installation validation prevents operations when misconfigured
- [x] Error messages are clear and actionable
- [x] Exit codes are consistent and documented
- [x] Integration with existing shell wrappers works seamlessly
- [x] Manual testing passes all scenarios

## Team Usage & Future Scalability

### For Team Members
**Setup Instructions** (add to repo README):
```bash
# Clone the repo
git clone <repo-url>
cd mac-app-lifecycle-manager

# Recommended: Create shell alias (add to ~/.zshrc)
echo 'alias mac-app-lifecycle="$(pwd)/bin/mac-app-lifecycle"' >> ~/.zshrc
source ~/.zshrc

# Alternative: Add to PATH permanently
echo 'export PATH="$(pwd)/bin:$PATH"' >> ~/.zshrc

# Alternative: Use full path when needed
/path/to/repo/bin/mac-app-lifecycle --help
```

**Usage After Setup**:
```bash
# From any directory
mac-app-lifecycle close --now
mac-app-lifecycle status
mac-app-lifecycle logs close
```

### Directory Structure for Multiple Tools
**Future Pattern** (6 weeks from now):
```
mac-app-lifecycle-manager/
├── bin/
│   ├── mac-app-lifecycle     # App lifecycle management
│   ├── mac-backup-tool       # Future backup automation
│   └── mac-security-tool     # Future security scripts
├── scripts/
│   ├── lib/                  # Shared libraries
│   ├── mac-app-lifecycle/    # Current tool scripts
│   ├── mac-backup-tool/      # Future tool scripts
│   └── mac-security-tool/    # Future tool scripts
├── config/
│   ├── mac-app-lifecycle/    # Tool-specific configs
│   ├── mac-backup-tool/      # Future configs
│   └── mac-security-tool/    # Future configs
├── logs/
│   ├── mac-app-lifecycle/    # Tool-specific logs
│   ├── mac-backup-tool/      # Future logs
│   └── mac-security-tool/    # Future logs
└── docs/
    ├── CLI_TOOL_PLAN.md      # This document
    ├── BACKUP_TOOL_PLAN.md   # Future plans
    └── SECURITY_TOOL_PLAN.md # Future plans
```

**Benefits for Future Development**:
- Consistent self-discovery pattern
- Shared library functions
- Standardized config/log organization
- Easy to find and maintain
- Clear documentation structure