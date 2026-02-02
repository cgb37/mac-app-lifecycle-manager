# Troubleshooting Guide

This guide helps resolve common issues with the macOS App Lifecycle Manager.

## Installation Issues

### Installation Script Fails

**Symptoms:** `install.sh` exits with error

**Common causes:**
- Not running on macOS
- macOS version too old (< 10.15)
- Missing required commands (`osascript`, `launchctl`)
- No write permission to `~/Library/LaunchAgents/`

**Solutions:**
```bash
# Check macOS version
sw_vers -productVersion

# Check required commands
which osascript launchctl

# Check permissions
ls -la ~/Library/LaunchAgents/
```

### launchd Agent Won't Load

**Symptoms:** `launchctl load` fails

**Causes:**
- Invalid plist syntax
- Missing script files
- Permission issues

**Solutions:**
```bash
# Validate plist syntax
plutil ~/Library/LaunchAgents/com.user.mac-app-lifecycle.close.plist

# Check script exists and is executable
ls -la scripts/close-apps/close-apps.sh

# Try manual load with verbose output
launchctl load -w ~/Library/LaunchAgents/com.user.mac-app-lifecycle.close.plist
```

### Permission Prompts During Installation

**Symptoms:** macOS asks for permissions during setup

**Solution:** Accept the prompts - they're required for the tool to work.

## Runtime Issues

### Apps Not Closing/Opening

**Symptoms:** Scripts run but apps don't respond

**Common causes:**
- Missing Accessibility permissions
- Missing Automation permissions for specific apps
- Apps already closed/opened
- Invalid app names/paths in config

**Solutions:**
1. **Check Accessibility permissions:**
   - System Settings → Privacy & Security → Accessibility
   - Ensure Terminal.app (or your terminal) is enabled

2. **Check Automation permissions:**
   - System Settings → Privacy & Security → Automation
   - Enable Terminal.app for each app you want to control

3. **Verify app lists:**
   ```bash
   cat config/apps-to-close.txt
   cat config/apps-to-open.txt
   ```

4. **Test manually:**
   ```bash
   ./bin/mac-app-lifecycle close --now
   ```

### Schedule Not Triggering

**Symptoms:** Agents loaded but don't run at scheduled times

**Causes:**
- Incorrect time format in plist
- System sleep/preferences
- launchd disabled

**Solutions:**
```bash
# Check agent status
launchctl list com.user.mac-app-lifecycle.close

# Check system time
date

# Check plist schedule
grep -A 5 StartCalendarInterval ~/Library/LaunchAgents/com.user.mac-app-lifecycle.close.plist

# Test manual trigger
launchctl start com.user.mac-app-lifecycle.close
```

### Scripts Exit with Errors

**Symptoms:** Non-zero exit codes, error logs

**Check logs:**
```bash
tail -f logs/close-apps.err
tail -f logs/open-apps.err
```

**Common errors:**
- Missing config files
- Invalid paths
- Permission denied on log files

## Configuration Issues

### Config File Not Found

**Symptoms:** Script complains about missing config

**Solution:** Ensure config files exist:
```bash
ls -la config/
# If missing, copy from examples
cp config/close-apps.conf.example config/close-apps.conf
```

### Invalid Time Format

**Symptoms:** Schedule validation fails

**Solution:** Use 24-hour format HH:MM (e.g., 19:00, 08:30)

### App Paths Incorrect

**Symptoms:** Apps not found

**Solutions:**
- Use full paths: `/Applications/AppName.app`
- Check case sensitivity
- Verify apps exist: `ls "/Applications/AppName.app"`

## Debugging

### Enable Debug Logging

Edit config files to increase verbosity:
```bash
# In config/close-apps.conf or config/open-apps.conf
LOG_LEVEL="DEBUG"
```

### Check Logs

View recent activity:
```bash
# Close-apps logs
tail -f logs/close-apps.log
tail -f logs/close-apps.err

# Open-apps logs
tail -f logs/open-apps.log
tail -f logs/open-apps.err

# Or use the CLI
./bin/mac-app-lifecycle logs close
./bin/mac-app-lifecycle logs open
```

### Test Scripts Manually

Run without launchd:
```bash
# Close apps
./scripts/close-apps/close-apps.sh

# Open apps
./scripts/open-apps/open-apps.sh

# Or use CLI
./bin/mac-app-lifecycle close --now
./bin/mac-app-lifecycle open --now
```

### Check launchd Status

```bash
# List loaded agents
launchctl list | grep mac-app-lifecycle

# Check specific agent
launchctl list com.user.mac-app-lifecycle.close

# View detailed status (macOS 11+)
launchctl print gui/$(id -u)/com.user.mac-app-lifecycle.close
```

## macOS Permissions

### Accessibility Permission

Required for AppleScript to control applications.

**Check:** System Settings → Privacy & Security → Accessibility

**Fix:** Add Terminal.app (or your script runner) to the list and enable it

### Automation Permission

Required for each app that will be controlled.

**Check:** System Settings → Privacy & Security → Automation

**Fix:** 
1. Find your terminal app in the list
2. Enable automation for each app you want to control
3. Accept prompts as they appear

### Full Disk Access

May be required for certain terminal applications.

**Check:** System Settings → Privacy & Security → Full Disk Access

**Fix:** Add Terminal.app if needed

## Getting Help

1. Check logs (see [Debugging](#debugging) above)
2. Review configuration (see [Configuration Reference](CONFIGURATION.md))
3. Test scripts manually before scheduled runs
4. Consult original implementation: `original-scripts-to-be-migrated/`

## Reporting Issues

When reporting issues, include:
- macOS version: `sw_vers -productVersion`
- Relevant log snippets
- Config files (sanitize personal paths)
- Steps to reproduce
- Expected vs. actual behavior

## See Also

- [Installation Guide](INSTALLATION.md) - Setup instructions
- [Configuration Reference](CONFIGURATION.md) - All config options
- [Migration Plan](MIGRATION_PLAN.md) - Development roadmap
