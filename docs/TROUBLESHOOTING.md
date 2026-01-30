# Troubleshooting Guide

> **Note:** This is a stub document for Phase 1. Common issues and solutions will be added as they are discovered during migration (Phases 2-6).

## Known Issues

Issues will be documented here as they are encountered during the migration process.

## Common Problems (Placeholder)

### Configuration Issues
*To be documented in Phase 2-3*

### Permission Errors
*To be documented during testing*

### Schedule Not Triggering
*To be documented in Phase 5*

### Apps Not Closing/Opening
*To be documented in Phase 2-3*

## Debugging

### Enable Debug Logging

Edit your config file:
```bash
# In ~/.config/mac-app-lifecycle/close-apps.conf or open-apps.conf
LOG_LEVEL="DEBUG"
```

### Check Logs

View recent logs:
```bash
# Close-apps logs
tail -f logs/close-apps.log
tail -f logs/close-apps.err

# Open-apps logs
tail -f logs/open-apps.log
tail -f logs/open-apps.err
```

### Test Scripts Manually

Run scripts directly (without launchd):
```bash
# Close apps
./scripts/close-apps/close-apps.sh

# Open apps
./scripts/open-apps/open-apps.sh
```

### Check launchd Status

```bash
# List loaded agents
launchctl list | grep mac-app-lifecycle

# Check specific agent
launchctl list com.user.mac-app-lifecycle.close
launchctl list com.user.mac-app-lifecycle.open

# View agent status (macOS 11+)
launchctl print gui/$(id -u)/com.user.mac-app-lifecycle.close
```

## macOS Permissions

### Accessibility Permission

Required for AppleScript to control applications.

**Check:** System Settings → Privacy & Security → Accessibility

**Fix:** Add Terminal.app (or your script runner) to the list

### Automation Permission

Required for each app that will be controlled.

**Check:** System Settings → Privacy & Security → Automation

**Fix:** Approve requests as they appear, or pre-approve Terminal.app

### Full Disk Access

May be required for certain apps or directories.

**Check:** System Settings → Privacy & Security → Full Disk Access

**Fix:** Add Terminal.app if needed

## Getting Help

1. Check logs (see [Debugging](#debugging) above)
2. Review configuration (see [Configuration Reference](CONFIGURATION.md))
3. Test scripts manually before scheduled runs
4. Consult original implementation: `original-scripts-to-be-migrated/`

## Reporting Issues

When reporting issues during development, include:
- macOS version
- Relevant log snippets
- Config file (sanitize personal paths)
- Steps to reproduce
- Expected vs. actual behavior

## See Also

- [Configuration Reference](CONFIGURATION.md) - All config options
- [Installation Guide](INSTALLATION.md) - Setup instructions
- [Migration Plan](MIGRATION_PLAN.md) - Development roadmap

---

**This document will be expanded during Phases 2-6 as issues are discovered and resolved.**
