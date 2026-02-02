# Testing Guide

This document describes the comprehensive testing suite for the mac-app-lifecycle-manager project, including available test scripts, what they test, and best practices for running and interpreting tests.

## Overview

The project includes multiple layers of testing to ensure reliability:

- **Shell Script Tests**: Validate core functionality of close-apps and open-apps scripts
- **CLI Tool Tests**: Test the command-line interface functionality
- **Integration Tests**: Verify end-to-end operation and component interaction
- **Release Tests**: Validate release tooling and processes

All tests are written in bash and follow consistent patterns with colored output, test counters, and clear pass/fail reporting.

## Available Test Scripts

### Core Functionality Tests

#### `npm run test:open-apps`
Tests the open-apps shell wrapper script.
- **What it tests**: Syntax validation, script executability, dry-run execution
- **Duration**: ~2-5 seconds
- **Dependencies**: Requires `scripts/open-apps/open-apps.sh` and valid config

#### `npm run test:close-apps`
Tests the close-apps shell wrapper script.
- **What it tests**: Syntax validation, script executability, dry-run execution
- **Duration**: ~2-5 seconds
- **Dependencies**: Requires `scripts/close-apps/close-apps.sh` and valid config

### CLI Tool Tests

#### `npm run test:cli`
Tests CLI command parsing and basic functionality.
- **What it tests**:
  - CLI script existence and executability
  - Bash syntax validation
  - Help command output
  - Version command output
  - Unknown command error handling
  - Missing command error handling
  - Status/logs command stubs
- **Duration**: ~1-2 seconds
- **Dependencies**: Requires `bin/mac-app-lifecycle`

#### `npm run test:cli-options`
Tests CLI option parsing and handling.
- **What it tests**:
  - `--dry-run` option for close/open commands
  - `--verbose` option for close/open commands
  - `--now` option for open command
  - Unknown option error handling
  - Multiple options combination
- **Duration**: ~5-10 seconds
- **Dependencies**: Requires `bin/mac-app-lifecycle` and valid config files

#### `npm run test:cli-integration`
Tests CLI integration with shell wrappers.
- **What it tests**:
  - Config file validation (temporarily removes config to test error handling)
  - End-to-end command execution with dry-run
  - Environment variable passing to shell scripts
  - Installation validation (scripts directory existence)
- **Duration**: ~10-15 seconds
- **Dependencies**: Requires `bin/mac-app-lifecycle`, shell scripts, and config files

### Release Process Tests

#### `npm run test:release-it`
Tests the release-it configuration and workflow.
- **What it tests**:
  - package.json existence and structure
  - .release-it.json configuration file
  - release-it package installation
  - conventional-changelog plugin installation
  - Release script executability
  - Git repository configuration
  - Dry-run release process
- **Duration**: ~5-10 seconds
- **Dependencies**: Requires release-it packages and git repository

### Comprehensive Test Suite

#### `npm run test:all`
Runs all tests in sequence for complete validation.
- **Execution order**:
  1. `test:open-apps`
  2. `test:close-apps`
  3. `test:cli`
  4. `test:cli-options`
  5. `test:cli-integration`
  6. `npm run test:release-it` (release-it tests)
- **Duration**: ~30-60 seconds
- **Use case**: Pre-commit validation, CI/CD pipelines, comprehensive testing

## Test Descriptions

### Shell Script Tests (`test-open-close-scripts.sh`)

This test file provides basic validation for the core shell wrapper scripts:

- **Syntax checking**: Uses `bash -n` to validate script syntax
- **Executability**: Verifies scripts have execute permissions
- **Dry-run execution**: Runs scripts with `DRY_RUN=1` to test logic without side effects
- **NPM script validation**: Confirms npm scripts exist in package.json

### CLI Command Tests (`test-cli-commands.sh`)

Comprehensive testing of CLI command parsing:

- **Script validation**: Ensures CLI script exists and is executable
- **Syntax validation**: Checks for bash syntax errors
- **Command functionality**: Tests help, version, and stub commands
- **Error handling**: Validates proper error codes and messages for invalid input
- **Exit codes**: Confirms correct exit codes (0=success, 1=error, 2=validation failure, etc.)

### CLI Options Tests (`test-cli-options.sh`)

Tests option parsing and command-line argument handling:

- **Option recognition**: Validates all supported options are accepted
- **Option execution**: Tests that options trigger correct behavior
- **Error handling**: Ensures unknown options produce appropriate errors
- **Option combinations**: Tests multiple options work together
- **Integration**: Verifies options are passed correctly to underlying scripts

### CLI Integration Tests (`test-cli-integration.sh`)

End-to-end testing of CLI with shell wrapper integration:

- **Config validation**: Tests CLI properly validates configuration file existence
- **Script execution**: Verifies CLI calls correct shell wrapper scripts
- **Environment variables**: Confirms DRY_RUN, LOG_LEVEL variables are passed
- **Error propagation**: Tests error handling when underlying scripts fail
- **Installation checks**: Validates required directories and files exist

### Log Rotation Tests (`test-log-rotation.sh`)

Tests the log rotation functionality:

- **Log file creation**: Tests log files are created correctly
- **Rotation triggers**: Tests size-based and time-based rotation
- **Backup creation**: Verifies old logs are properly archived
- **Cleanup**: Tests old log removal after retention period

### Release Process Tests (`test-release-it.sh`)

Validates the release tooling configuration:

- **Configuration files**: Checks .release-it.json and package.json structure
- **Dependencies**: Verifies required npm packages are installed
- **Scripts**: Tests release script executability
- **Git integration**: Validates git repository state
- **Dry-run capability**: Tests release process without making changes

## Running Tests

### Individual Test Execution

```bash
# Test specific components
npm run test:open-apps      # Test open-apps script
npm run test:close-apps     # Test close-apps script
npm run test:cli           # Test CLI commands
npm run test:cli-options   # Test CLI options
npm run test:cli-integration # Test CLI integration

# Test release process
npm run test:release-it                   # Test release-it configuration
```

### Comprehensive Testing

```bash
# Run all tests (recommended for development)
npm run test:all
```

### Continuous Integration

For CI/CD pipelines, use:

```bash
# Exit on first failure
npm run test:all

# Or run tests individually for better error isolation
npm run test:open-apps && \
npm run test:close-apps && \
npm run test:cli && \
npm run test:cli-options && \
npm run test:cli-integration && \
npm run test:release-it
```

## Test Results Interpretation

### Success Indicators

- **Exit code 0**: All tests in the script passed
- **Green ✓ symbols**: Individual test assertions passed
- **"All X tests passed!"**: Complete test suite success
- **Test counters**: Shows total tests run vs passed/failed

### Failure Indicators

- **Exit code 1**: One or more tests failed
- **Red ✗ symbols**: Individual test assertions failed
- **"X tests failed"**: Summary of failed tests
- **Error messages**: Specific details about what failed

### Test Output Format

```
=== Testing CLI Commands ===

Test 1: CLI script exists and is executable
==================================================
✓ CLI script found: /path/to/script
✓ CLI script is executable

Test 2: CLI script syntax validation
==================================================
✓ CLI script syntax is valid

==================================================
Test Summary:
  Total: 8
  Passed: 11
  Failed: 0

✓ All CLI command tests passed!
```

## Best Practices

### Development Workflow

1. **Run tests before committing**: Use `npm run test:all` to catch issues early
2. **Test individual components**: Use specific test scripts when debugging
3. **Check test output**: Review colored output for specific failures
4. **Fix failures immediately**: Don't commit with failing tests

### Test Maintenance

1. **Update tests with code changes**: Modify tests when functionality changes
2. **Add tests for new features**: Create tests for new CLI commands or options
3. **Review test coverage**: Ensure critical paths are tested
4. **Keep tests fast**: Optimize tests to run quickly in development

### CI/CD Integration

1. **Use test:all in pipelines**: Comprehensive validation for automated builds
2. **Fail fast on errors**: Stop pipeline on test failures
3. **Archive test results**: Save test output for debugging
4. **Parallel execution**: Consider running tests in parallel for speed

### Debugging Failed Tests

1. **Run individual tests**: Isolate failures with specific npm scripts
2. **Check dependencies**: Ensure config files and scripts exist
3. **Review error messages**: Look for specific failure reasons
4. **Check environment**: Verify required tools and permissions
5. **Run with verbose output**: Some tests show detailed execution logs

## Troubleshooting

### Common Issues

#### "CLI script not found" or "Script not executable"
- **Cause**: Missing or incorrect permissions on `bin/mac-app-lifecycle`
- **Solution**: Run `chmod +x bin/mac-app-lifecycle`

#### "Config file not found" errors
- **Cause**: Missing configuration files in `config/` directory
- **Solution**: Copy example configs: `cp config/*.example config/`

#### "Scripts directory missing"
- **Cause**: `scripts/` directory not found or incomplete
- **Solution**: Check project structure and restore missing files

#### Release-it test failures
- **Cause**: Missing dependencies or git configuration issues
- **Solution**: Run `npm install` and check git repository state

#### Syntax errors in scripts
- **Cause**: Bash syntax issues in shell scripts
- **Solution**: Run `bash -n script.sh` to identify syntax problems

### Environment Requirements

Tests require:
- **Bash 3.2+** (macOS default)
- **Node.js and npm** for package scripts
- **Git repository** for release tests
- **Valid configuration files** in `config/` directory
- **Executable permissions** on scripts in `bin/` and `scripts/`

### Performance Considerations

- **CLI tests**: Fast (~1-2 seconds each)
- **Integration tests**: Medium (~5-15 seconds)
- **Release tests**: Medium (~5-10 seconds)
- **Complete suite**: ~30-60 seconds

Run individual tests during development and full suite for comprehensive validation.

