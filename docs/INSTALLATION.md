# Installation Guide

This guide covers installing the macOS App Lifecycle Manager using the automated installation script.

## Quick Start

1. **Download and extract:**
   ```bash
   # Download the latest release or clone the repository
   git clone <repository-url>
   cd mac-app-lifecycle-manager
   ```

2. **Run the installer:**
   ```bash
   ./install.sh
   ```

3. **Follow the prompts:**
   - Enter your preferred close and open times
   - The script will set up everything automatically

4. **Configure permissions** (see below)

5. **Test the installation:**
   ```bash
   ./bin/mac-app-lifecycle status
   ./bin/mac-app-lifecycle close --now
   ```

## Automated Installation

The `install.sh` script handles the complete setup:

### What it does:
- Prompts for schedule times (close apps, open apps)
- Copies configuration templates to user files
- Creates the logs directory
- Generates launchd plist files from templates
- Copies plists to `~/Library/LaunchAgents/`
- Sets executable permissions on scripts
- Loads the launchd agents
- Validates the installation
- Provides permission setup instructions

### Options:
- `--dry-run`: Show what would be done without making changes
- `--verbose`: Enable verbose output

### Example:
```bash
# Dry run first
./install.sh --dry-run

# Full installation
./install.sh

# Verbose installation
./install.sh --verbose
```

## System Requirements

- **macOS**: 10.15 (Catalina) or later
- **Commands**: `osascript`, `launchctl` (included with macOS)
- **Shell**: Bash 3.2+ or zsh

## Required Permissions

After installation, configure these macOS permissions:

### 1. Accessibility Permissions
Required for AppleScript to control applications.

1. Open **System Settings** → **Privacy & Security** → **Accessibility**
2. Click the **+** button
3. Add your terminal application (Terminal.app, iTerm.app, etc.)
4. Ensure it's enabled (checkmark)

### 2. Automation Permissions
Required for controlling other applications.

1. Open **System Settings** → **Privacy & Security** → **Automation**
2. Find your terminal application in the list
3. Enable automation for the applications you want to control:
   - Apps you want to close (from `apps-to-close.txt`)
   - Apps you want to open (from `apps-to-open.txt`)

### 3. Full Disk Access (if needed)
May be required for some terminal applications.

1. Open **System Settings** → **Privacy & Security** → **Full Disk Access**
2. Click the **+** button
3. Add your terminal application

### Testing Permissions
After setting permissions, test with:
```bash
./bin/mac-app-lifecycle close --now
```

If you see permission prompts, accept them and try again.

## Manual Setup (Development)

For development or manual installation:

1. **Copy config templates:**
   ```bash
   cp config/close-apps.conf.example config/close-apps.conf
   cp config/open-apps.conf.example config/open-apps.conf
   cp config/apps-to-close.txt.example config/apps-to-close.txt
   cp config/apps-to-open.txt.example config/apps-to-open.txt
   ```

2. **Edit configurations:**
   ```bash
   # Customize schedules and paths
   vim config/close-apps.conf
   vim config/open-apps.conf
   ```

3. **Create logs directory:**
   ```bash
   mkdir -p logs
   ```

4. **Generate launchd plists:**
   ```bash
   # Use the templates in launchd/ directory
   # Customize schedule times in the generated plists
   cp launchd/com.user.mac-app-lifecycle.close.plist.template ~/Library/LaunchAgents/com.user.mac-app-lifecycle.close.plist
   cp launchd/com.user.mac-app-lifecycle.open.plist.template ~/Library/LaunchAgents/com.user.mac-app-lifecycle.open.plist
   ```

5. **Set permissions and load:**
   ```bash
   chmod +x bin/mac-app-lifecycle scripts/*/close-apps.sh scripts/*/open-apps.sh
   launchctl load ~/Library/LaunchAgents/com.user.mac-app-lifecycle.close.plist
   launchctl load ~/Library/LaunchAgents/com.user.mac-app-lifecycle.open.plist
   ```

## Uninstallation

To remove the macOS App Lifecycle Manager:

```bash
./uninstall.sh
```

The uninstaller will:
- Unload launchd agents
- Remove plist files
- Optionally remove config files and logs (with confirmation)

Note: macOS permissions are not automatically removed - disable them manually in System Settings.

## Verification

After installation, verify everything works:

```bash
# Check agent status
./bin/mac-app-lifecycle status

# Test manual operations
./bin/mac-app-lifecycle close --now
./bin/mac-app-lifecycle open --now

# Check logs
./bin/mac-app-lifecycle logs close
./bin/mac-app-lifecycle logs open
```

## Troubleshooting

If installation fails:
- Check the error messages from `install.sh`
- Ensure you're running on macOS 10.15+
- Verify you have write access to `~/Library/LaunchAgents/`
- See [Troubleshooting Guide](TROUBLESHOOTING.md) for common issues

## Configuration

After installation, customize behavior by editing:
- `config/close-apps.conf` - Close apps configuration
- `config/open-apps.conf` - Open apps configuration
- `config/apps-to-close.txt` - List of apps to close
- `config/apps-to-open.txt` - List of apps to open

See [Configuration Reference](CONFIGURATION.md) for details.

## Documentation

- [Configuration Reference](CONFIGURATION.md) - All config options
- [Troubleshooting Guide](TROUBLESHOOTING.md) - Common issues
- [Migration Plan](MIGRATION_PLAN.md) - Development roadmap
