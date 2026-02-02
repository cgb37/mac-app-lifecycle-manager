# Release Process

## Quick Start

**TL;DR:** After merging to main, run:
```bash
npm run release        # Interactive (auto-detects version bump)
npm run release:patch  # Force patch version (0.1.0 → 0.1.1)
npm run release:minor  # Force minor version (0.1.0 → 0.2.0)
npm run release:major  # Force major version (0.1.0 → 1.0.0)
```

This will:
1. Analyze commits since last release
2. Auto-generate CHANGELOG.md
3. Bump version in all files
4. Create git tag and GitHub release
5. Push everything to remote

---

## Overview

This project uses [release-it](https://github.com/release-it/release-it) with the [conventional-changelog](https://github.com/release-it/conventional-changelog) plugin to automate versioning and releases. Releases follow [Semantic Versioning](https://semver.org/) and [Conventional Commits](https://www.conventionalcommits.org/).

### What Happens During a Release

1. **Analyze commits** - Scans commit messages since last release
2. **Determine version bump** - Based on commit types (feat/fix/BREAKING)
3. **Update CHANGELOG.md** - Auto-generates from conventional commits
4. **Bump versions** - Updates package.json + shell scripts + docs + plist files
5. **Git commit & tag** - Creates release commit with version tag
6. **Push to GitHub** - Pushes commits and tags
7. **Create GitHub release** - Publishes release with auto-generated notes

---

## Prerequisites

### 1. Install Dependencies

```bash
npm install
```

This installs:
- `release-it` - Release automation tool
- `@release-it/conventional-changelog` - Conventional commits integration
- `conventional-changelog-cli` - Standalone changelog generator

### 2. Commit Message Format

**All commits must follow conventional commit format:**

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat:` - New feature (triggers **minor** version bump)
- `fix:` - Bug fix (triggers **patch** version bump)
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting)
- `refactor:` - Code refactoring
- `perf:` - Performance improvements
- `test:` - Test additions/changes
- `chore:` - Build process, tooling, dependencies

**Breaking Changes:**
- Add `BREAKING CHANGE:` in footer or `!` after type (triggers **major** version bump)

**Examples:**
```bash
git commit -m "feat(close-apps): add timeout configuration for app closing"
git commit -m "fix(open-apps): resolve whitelist path resolution issue"
git commit -m "docs: update installation instructions"
git commit -m "feat(close-apps)!: change config file format

BREAKING CHANGE: Configuration file now requires YAML format"
```

### 3. GitHub Authentication

You have two options for providing your GitHub token:

**Option A: Shell Environment (Recommended)**
```bash
# Add to ~/.zshrc for persistence
export GITHUB_TOKEN="your_token_here"

# Or set for current session
export GITHUB_TOKEN="your_token_here"
```

**Option B: .env File**
```bash
# Copy example and add your token
cp .env.example .env
vim .env  # Add your token

# The release script will automatically load it
```

**Priority:** Shell environment variables take precedence over `.env` file.

**Create token at:** https://github.com/settings/tokens (needs `repo` scope)

---

## Release Commands

### Interactive Release (Recommended)

```bash
npm run release
```

- **Auto-detects** version bump from commits
- **Interactive prompts** for confirmation
- Best for most releases

### Force Specific Version Bump

```bash
npm run release:major  # 0.1.0 → 1.0.0
npm run release:minor  # 0.1.0 → 0.2.0
npm run release:patch  # 0.1.0 → 0.1.1
```

Use when you want to **override** auto-detection.

### Set Custom Version

```bash
npm run release:set
```

Prompts for **exact version** to set (e.g., 1.0.0-beta.1).

### Dry Run (Test Without Changes)

```bash
./scripts/release.sh --dry-run
```

**Simulates** the entire release process without:
- Creating commits
- Pushing to remote
- Creating GitHub release

Perfect for **validating** your setup.

---

## Release Workflow

### Step 1: Merge PR to Main

Ensure your PR has been merged to the `main` branch with conventional commits.

### Step 2: Pull Latest Changes

```bash
git checkout main
git pull origin main
```

### Step 3: Run Release

```bash
npm run release
```

### Step 4: Verify Release

1. **Check CHANGELOG.md** - Review generated changelog entries
2. **GitHub Releases** - Verify release appears on GitHub
3. **Git Tags** - Confirm tag was pushed: `git tag -l`
4. **Version Files** - Check versions updated in:
   - [package.json](../package.json)
   - [scripts/close-apps/close-apps.sh](../scripts/close-apps/close-apps.sh)
   - [scripts/open-apps/open-apps.sh](../scripts/open-apps/open-apps.sh)
   - [launchd plist templates](../launchd/)

---

## Files Updated During Release

The version bump updates these files automatically:

| File | Update Pattern |
|------|----------------|
| [package.json](../package.json) | `"version": "x.y.z"` |
| Shell scripts | `# Version: x.y.z` (header comment) |
| Launchd plists | `<!-- Version: x.y.z -->` (XML comment) |
| [README.md](../README.md) | `Version: **x.y.z**` (badges/headers) |
| [docs/INSTALLATION.md](../INSTALLATION.md) | Version references |
| [CHANGELOG.md](../CHANGELOG.md) | Auto-generated from commits |

**Implementation:** See [scripts/update-version.sh](../scripts/update-version.sh)

---

## Configuration

### .release-it.json

Main configuration file for release-it behavior:

```json
{
  "git": {
    "commitMessage": "chore(release): ${version}",
    "requireBranch": "main"
  },
  "github": {
    "release": true
  },
  "plugins": {
    "@release-it/conventional-changelog": {
      "preset": "angular",
      "infile": "CHANGELOG.md"
    }
  }
}
```

**Key Settings:**
- `requireBranch: "main"` - Only allow releases from main branch
- `requireCleanWorkingDir: true` - No uncommitted changes allowed
- `preset: "angular"` - Use Angular commit convention

### package.json Scripts

```json
{
  "scripts": {
    "changelog": "conventional-changelog -p angular -i CHANGELOG.md -s",
    "release": "bash ./scripts/release.sh",
    "release:major": "bash ./scripts/release.sh major",
    "release:minor": "bash ./scripts/release.sh minor",
    "release:patch": "bash ./scripts/release.sh patch"
  }
}
```

---

## Testing

Run the test suite to validate release configuration:

```bash
npm test
# or
./tests/test-release-it.sh
```

**Tests include:**
- Configuration file validation
- Script executability
- Dependency installation
- Dry-run execution
- Git repository checks

---

## Troubleshooting

### Problem: "Git working directory not clean"

**Solution:**
```bash
git status                    # Check uncommitted changes
git add -A && git commit -m "..." # Commit or stash changes
```

### Problem: "Not on main branch"

**Solution:**
```bash
git checkout main
git pull origin main
```

### Problem: "GitHub token not configured"

**Solution:**
```bash
export GITHUB_TOKEN="your_token_here"
# or add to ~/.zshrc for persistence
```

### Problem: "No commits since last release"

**Cause:** Trying to release when no new commits exist since last tag.

**Solution:** Wait until more commits are merged.

### Problem: "Failed to push tags"

**Cause:** Typically network issues or permission problems.

**Solution:**
```bash
git push origin main --tags  # Manually push tags
```

### Problem: "Version update hook failed"

**Cause:** [scripts/update-version.sh](../scripts/update-version.sh) encountered an error.

**Solution:**
1. Check script has execute permissions: `chmod +x scripts/update-version.sh`
2. Run manually to see errors: `./scripts/update-version.sh 0.1.0`
3. Verify files exist that script tries to update

---

## Manual Changelog Generation

Generate changelog without releasing:

```bash
npm run changelog
```

This updates [CHANGELOG.md](../CHANGELOG.md) based on commits since last tag.

---

## Version Rollback

If a release goes wrong:

### 1. Delete Local Tag
```bash
git tag -d v1.0.0
```

### 2. Delete Remote Tag
```bash
git push origin :refs/tags/v1.0.0
```

### 3. Delete GitHub Release
Go to GitHub → Releases → Delete the release

### 4. Reset Commits
```bash
git reset --hard HEAD~1  # Reset release commit
git push origin main --force
```

⚠️ **Warning:** Force pushing can disrupt collaborators. Coordinate with team.

---

## Best Practices

### ✓ Do's

- **Commit frequently** with descriptive conventional commit messages
- **Test locally** before pushing commits
- **Run dry-run** before actual release: `./scripts/release.sh --dry-run`
- **Review CHANGELOG** after generation
- **Release from main** branch only
- **Pull latest** before releasing

### ✗ Don'ts

- **Don't release** with uncommitted changes
- **Don't manually edit** version in package.json
- **Don't create tags manually**
- **Don't skip commit message format**
- **Don't release** without testing

---

## CI/CD Integration (Future)

Currently releases are **manual** (run by developer after PR merge). Future enhancements:

### GitHub Actions Workflow

```yaml
# .github/workflows/release.yml
name: Release
on:
  workflow_dispatch:  # Manual trigger
    inputs:
      version:
        description: 'Version bump type'
        required: true
        default: 'auto'
        type: choice
        options:
          - auto
          - major
          - minor
          - patch
```

### Automated Releases

- Trigger on PR merge to main with label `release:*`
- Auto-detect version from commits
- Create release without manual intervention

---

## See Also

- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [release-it Documentation](https://github.com/release-it/release-it)
- [Conventional Changelog](https://github.com/conventional-changelog/conventional-changelog)
- [CONFIGURATION.md](CONFIGURATION.md) - Project configuration guide
- [INSTALLATION.md](INSTALLATION.md) - Installation instructions
