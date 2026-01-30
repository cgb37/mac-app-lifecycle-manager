# Migration Plan: macOS App Lifecycle Manager

## Overview
Migrate legacy AppleScript-based automation into a unified, portable, config-driven system.

**Key Decisions:**
- Keep AppleScript for macOS app control
- Separate configs: `close-apps.conf`, `open-apps.conf`
- Separate data files: `apps-to-close.txt`, `apps-to-open.txt`
- Schedule configurable via config files
- CLI tool for manual operations (`mac-app-lifecycle close --now`)
- Include uninstall script

---

## Target Directory Structure

```
mac-app-lifecycle-manager/
├── .github/
│   └── copilot-instructions.md
├── bin/
│   └── mac-app-lifecycle              # Main CLI entry point
├── scripts/
│   ├── close-apps/
│   │   ├── close-apps.applescript     # App closing logic
│   │   ├── close-apps.sh              # Shell wrapper
│   │   └── apps-to-close.txt          # List of apps to close
│   ├── open-apps/
│   │   ├── open-apps.applescript      # App opening logic
│   │   ├── open-apps.sh               # Shell wrapper
│   │   └── apps-to-open.txt           # Whitelist of apps to open
│   └── lib/
│       └── common.sh                  # Shared functions (logging, validation)
├── config/
│   ├── close-apps.conf.example        # Template for close config
│   ├── open-apps.conf.example         # Template for open config
│   └── README.md                      # Config documentation
├── launchd/
│   ├── com.user.mac-app-lifecycle.close.plist.template
│   └── com.user.mac-app-lifecycle.open.plist.template
├── install.sh                         # Installation script
├── uninstall.sh                       # Cleanup script
├── docs/
│   ├── INSTALLATION.md                # Installation guide
│   ├── CONFIGURATION.md               # Config reference
│   └── TROUBLESHOOTING.md             # Common issues
├── original-scripts-to-be-migrated/   # Keep for reference
└── README.md                          # Main documentation
```

---

## Phase 1: Foundation (Structure + Config System + Docs)

**Goal:** Establish directory structure, config system, and documentation foundation.

### Deliverables:
1. ✅ Create directory structure
2. ✅ Create config templates with all parameters
3. ✅ Create app list file examples
4. ✅ Document config system in `config/README.md`
5. ✅ Create `docs/CONFIGURATION.md` with all options
6. ✅ Update main `README.md` with project overview
7. ✅ Create `bin/mac-app-lifecycle` stub with help text

### Files to Create:
- `bin/mac-app-lifecycle` (stub with --help)
- `config/close-apps.conf.example`
- `config/open-apps.conf.example`
- `config/README.md`
- `scripts/close-apps/apps-to-close.txt.example`
- `scripts/open-apps/apps-to-open.txt.example`
- `scripts/lib/common.sh` (logging functions only)
- `docs/CONFIGURATION.md`
- `docs/INSTALLATION.md` (stub)
- `docs/TROUBLESHOOTING.md` (stub)
- Update `README.md`

### Commit Message:
```
Phase 1: Foundation - Directory structure, config system, and documentation

- Create unified directory structure with bin/, scripts/, config/, launchd/
- Add config templates with all parameters documented
- Add app list file examples with three-tier closing strategy
- Document configuration system comprehensively
- Add CLI stub with help text
- Update main README with project overview
```

---

## Phase 2: Close-Apps Implementation

**Goal:** Migrate and enhance close-apps functionality.

### Deliverables:
1. ✅ Migrate `CloseAllApps.applescript` → `close-apps.applescript`
   - Keep three-tier closing logic (name/path/force)
   - Accept parameters from shell wrapper
   - Improve error messages and logging
2. ✅ Create `close-apps.sh` wrapper
   - Load config from `close-apps.conf`
   - Validate app list file exists
   - Pass parameters to AppleScript
   - Structured logging with timestamps
   - Console output for manual runs
3. ✅ Create `apps-to-close.txt` with documented format
4. ✅ Update `common.sh` with shared functions
5. ✅ Create launchd plist template
6. ✅ Test manually: `./scripts/close-apps/close-apps.sh`

### Key Improvements:
- No hardcoded paths (use `$SCRIPT_DIR`, `$HOME`)
- Config-driven app list location
- Better error handling (missing files, permission issues)
- Structured logging: `[TIMESTAMP] [LEVEL] Message`
- Exit codes: 0 (success), 1 (error), 2 (config error)

### Commit Message:
```
Phase 2: Close-apps implementation with config-driven design

- Migrate AppleScript with three-tier closing logic
- Add shell wrapper with config loading and validation
- Implement structured logging with timestamps
- Create launchd plist template
- Document app list format with examples
- All paths configurable, no hardcoded values
```

---

## Phase 3: Open-Apps Implementation

**Goal:** Migrate and enhance open-apps functionality.

### Deliverables:
1. ✅ Migrate `OpenWhitelistApps.scpt` → `open-apps.applescript`
   - Accept parameters from shell wrapper
   - Support primary app (opened first)
   - Configurable stagger/post-launch delays
   - Better error handling
2. ✅ Create `open-apps.sh` wrapper
   - Load config from `open-apps.conf`
   - Validate whitelist file exists
   - Pass parameters to AppleScript
   - Structured logging matching close-apps
3. ✅ Create `apps-to-open.txt` with documented format
4. ✅ Create launchd plist template
5. ✅ Test manually: `./scripts/open-apps/open-apps.sh`

### Key Improvements:
- Consistent structure with close-apps
- Same logging format and error handling
- Config-driven whitelist location
- Optional primary app feature

### Commit Message:
```
Phase 3: Open-apps implementation with unified approach

- Migrate AppleScript with configurable delays
- Add shell wrapper matching close-apps structure
- Implement consistent logging and error handling
- Create launchd plist template
- Document whitelist format and primary app feature
```

---

## Phase 4: CLI Tool Implementation

**Goal:** Create user-facing CLI for manual operations.

### Deliverables:
1. ✅ Implement `bin/mac-app-lifecycle` with subcommands:
   - `close [--now]` - Close apps immediately
   - `open [--now]` - Open apps immediately
   - `status` - Show launchd agent status
   - `logs [close|open]` - Display recent logs
   - `--help` - Show usage
   - `--version` - Show version
2. ✅ Add dry-run mode: `--dry-run`
3. ✅ Add verbose mode: `--verbose`
4. ✅ Validate installation before operations

### Key Features:
- Invoke shell wrappers with proper error handling
- Pretty console output (colored if supported)
- Check if launchd agents are loaded
- Tail log files with formatting
- Exit codes for scripting

### Commit Message:
```
Phase 4: CLI tool for manual operations and status checks

- Add mac-app-lifecycle command with subcommands
- Implement close/open/status/logs operations
- Add dry-run and verbose modes
- Pretty console output with error handling
- Validate installation and configs before operations
```

---

## Phase 5: Installation & Uninstall Scripts

**Goal:** Automate setup and cleanup.

### Deliverables:
1. ✅ Create `install.sh`:
   - Interactive prompts for schedule times
   - Copy config templates to `~/.config/mac-app-lifecycle/`
   - Create log directory: `~/Library/Logs/mac-app-lifecycle/`
   - Copy app list files to config directory
   - Generate plist files from templates with user's schedule
   - Copy plists to `~/Library/LaunchAgents/`
   - Set executable permissions
   - Load launchd agents
   - Validate installation
   - Instructions for permissions (Accessibility, Automation)
2. ✅ Create `uninstall.sh`:
   - Unload launchd agents
   - Remove plists from `~/Library/LaunchAgents/`
   - Optionally remove config directory
   - Optionally remove logs
   - Confirmation prompts (especially for config/logs)
3. ✅ Update `docs/INSTALLATION.md` with step-by-step guide
4. ✅ Update `docs/TROUBLESHOOTING.md` with common issues

### Key Features:
- Non-destructive (backup existing configs)
- Validate macOS version (10.15+)
- Check for required commands (osascript, launchctl)
- Clear success/error messages
- Idempotent (safe to run multiple times)

### Commit Message:
```
Phase 5: Installation and uninstall automation

- Add interactive install.sh with schedule configuration
- Add uninstall.sh with confirmation prompts
- Generate launchd plists from templates
- Set up config directory and log directory
- Validate installation and provide clear feedback
- Update installation and troubleshooting docs
```

---

## Phase 6: Testing & Polish

**Goal:** Manual validation and refinement.

### Deliverables:
1. ✅ Manual testing checklist:
   - Fresh installation on clean system
   - Config modifications work correctly
   - Both schedules trigger properly
   - Manual CLI operations work
   - Uninstall removes everything
   - Logs are created and rotated
2. ✅ Edge case handling:
   - Missing config files
   - Empty app lists
   - Invalid paths
   - Apps already running/closed
   - Permission denied scenarios
3. ✅ Documentation review:
   - All examples work
   - Screenshots/examples added
   - Common workflows documented
4. ✅ Update `.gitignore` for local files
5. ✅ Add `CHANGELOG.md`

### Commit Message:
```
Phase 6: Testing, edge case handling, and documentation polish

- Add manual testing checklist
- Improve error handling for edge cases
- Enhance documentation with examples
- Add CHANGELOG.md
- Update .gitignore for local configs/logs
```

---

## Phase 7: Final Documentation & Release

**Goal:** Production-ready documentation and release prep.

### Deliverables:
1. ✅ Comprehensive `README.md`:
   - Feature overview
   - Quick start guide
   - Screenshots/examples
   - Link to detailed docs
   - Contribution guidelines
2. ✅ Create `CONTRIBUTING.md`
3. ✅ Add LICENSE (if applicable)
4. ✅ Version tagging: `v1.0.0`
5. ✅ Archive original scripts:
   - Move to `docs/original-implementation/`
   - Add reference note in README
6. ✅ Final validation:
   - All links work
   - All examples tested
   - Installation on fresh system successful

### Commit Message:
```
Phase 7: Final documentation and v1.0.0 release

- Complete comprehensive README with examples
- Add CONTRIBUTING.md and LICENSE
- Archive original scripts with documentation
- Validate all documentation links and examples
- Tag v1.0.0 release
```

---

## Notes for Each Phase

### Testing Strategy:
- **During development:** Manual script execution only
- **After Phase 5:** Test full installation/uninstall cycle
- **Before Phase 7:** Fresh system validation

### Commit Frequency:
- Commit after each complete phase
- Additional commits within phases if logical breakpoints exist
- Each commit should leave system in working state (or clearly marked WIP)

### Git Workflow:
```bash
# Start new phase
git checkout -b phase-N-description

# Work on deliverables...
git add .
git commit -m "Phase N: Title

- Bullet points of changes
"

# Merge when phase complete and tested
git checkout main
git merge phase-N-description
git tag phase-N  # Optional milestone tags
```

### Documentation Updates:
Update `.github/copilot-instructions.md` after Phase 5 with:
- New directory structure
- Installation workflow
- CLI usage patterns
- Any discovered issues/gotchas

---

## Risk Mitigation

**Potential Issues:**
1. **macOS permissions** - Document in TROUBLESHOOTING.md, add detection in install.sh
2. **Schedule conflicts** - Validate user-provided times in install.sh
3. **App path changes** - Document format in apps-to-close.txt with examples
4. **launchd timing issues** - Keep shell wrapper pattern, add delays if needed

**Rollback Strategy:**
- Keep `original-scripts-to-be-migrated/` until Phase 7
- Uninstall script can revert to working state
- Each phase independently functional

---

## Success Criteria

**Phase 1 Complete:** Structure exists, configs documented, can proceed with implementation
**Phase 2 Complete:** Close-apps works manually, no errors in logs
**Phase 3 Complete:** Open-apps works manually, consistent with close-apps
**Phase 4 Complete:** CLI tool works for all operations, clear output
**Phase 5 Complete:** Fresh installation succeeds, uninstall removes everything
**Phase 6 Complete:** Edge cases handled, documentation accurate
**Phase 7 Complete:** Ready for public use, all docs validated

---

## Ready to Start?

**Next Action:** Begin Phase 1 - Foundation

Run: Create directory structure and foundational files.

Confirm you're ready to proceed, and I'll start implementing Phase 1.
