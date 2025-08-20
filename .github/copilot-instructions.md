# flutter_dotenv

flutter_dotenv is a Flutter/Dart package that loads configuration at runtime from a `.env` file which can be used throughout the application. This follows the twelve-factor app methodology for configuration management.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Quick Reference

**Essential Commands (run in repository root):**
```bash
flutter pub get                    # Install dependencies (30-90s, timeout: 120s+)
flutter analyze                    # Static analysis (10-30s, timeout: 60s+) 
flutter test --coverage            # Run all tests (30-60s, timeout: 120s+)
dart format lib/ test/ example/lib/ # Format code (5-15s, timeout: 30s+)
```

**Example App Commands (run in example/ directory):**
```bash
cd example/
flutter pub get                    # Install example deps (30-90s, timeout: 120s+)
flutter run                        # Launch app (60-180s, timeout: 300s+)
flutter run -d chrome              # Launch in web browser
```

**Critical Reminder**: NEVER CANCEL any of these operations. Always set timeouts 2-3x the expected time.

## Working Effectively

### Prerequisites and Environment Setup
- Install Flutter SDK (stable channel recommended):
  ```bash
  # Option 1: Using snap (Linux)
  sudo snap install flutter --classic
  
  # Option 2: Manual installation
  git clone https://github.com/flutter/flutter.git -b stable
  export PATH="$PATH:`pwd`/flutter/bin"
  ```
- Verify installation: `flutter doctor`
- Ensure Dart SDK is included with Flutter (no separate installation needed)

### Bootstrap, Build, and Test Repository
**CRITICAL TIMING**: All commands below have specific timeout requirements. NEVER CANCEL these operations.

```bash
# Navigate to repository
cd /home/runner/work/flutter_dotenv/flutter_dotenv

# Get dependencies - takes 30-90 seconds. NEVER CANCEL. Set timeout to 120+ seconds.
flutter pub get

# Run static analysis - takes 10-30 seconds. NEVER CANCEL. Set timeout to 60+ seconds.
flutter analyze

# Run tests with coverage - takes 30-60 seconds. NEVER CANCEL. Set timeout to 120+ seconds.
flutter test --coverage

# Format code (if making changes) - takes 5-15 seconds. NEVER CANCEL. Set timeout to 30+ seconds.
dart format lib/ test/ example/lib/
```

### Development Workflow
- **ALWAYS run `flutter pub get` first** after cloning or when dependencies change
- **ALWAYS run `flutter analyze`** before making changes to understand current state
- **ALWAYS run `flutter test`** to verify functionality
- **ALWAYS run `dart format`** before committing (CI will fail otherwise)

### Running the Example Application
- Navigate to example directory: `cd example/`
- Get example dependencies: `flutter pub get` - takes 30-90 seconds. NEVER CANCEL. Set timeout to 120+ seconds.
- Run example app: `flutter run` - takes 60-180 seconds to build and launch. NEVER CANCEL. Set timeout to 300+ seconds.
- For web: `flutter run -d chrome`
- Note: Example demonstrates loading .env files with environment variables

## Validation

### Manual Testing Scenarios
**CRITICAL**: After making ANY changes, ALWAYS run through these validation scenarios:

1. **Basic .env Loading Test**:
   ```bash
   cd example/
   flutter run
   # Verify the app loads and displays environment variables from assets/.env
   # Check that FOO=foo, BAR=bar, and FOOBAR=\$FOOfoobar display correctly
   # Verify ESCAPED_DOLLAR_SIGN shows "\$1000" properly
   ```

2. **Parser Functionality Test**:
   ```bash
   flutter test test/parser_test.dart --verbose
   # Verify all parser tests pass:
   # - Variable substitution (\$FOO${FOO} patterns)
   # - Quote handling (single/double quotes, nested quotes)
   # - Comment parsing (# comments are ignored)
   # - Equal signs in values (foo=bar=baz handling)
   # - Leading export keyword removal
   ```

3. **DotEnv Integration Test**:
   ```bash
   flutter test test/dotenv_test.dart --verbose
   # Verify core functionality:
   # - Environment loading with loadFromString()
   # - Fallback values work (get() with fallback parameter)
   # - Type conversions (getInt, getBool, getDouble)
   # - Null safety (maybeGet returns null for missing keys)
   ```

4. **Empty Environment Test**:
   ```bash
   flutter test test/empty_env_test.dart --verbose
   # Verify edge cases when no .env file exists
   # Ensures graceful fallback behavior
   ```

5. **Override and Merging Test**:
   ```bash
   # Check that .env-override functionality works in tests
   grep -r "override" test/ example/
   # Verify overrideWith and mergeWith parameters work correctly
   ```

### CI/CD Validation
- **ALWAYS run `flutter analyze`** - CI uses this for static analysis
- **ALWAYS run `flutter test --coverage`** - CI requires test coverage
- **ALWAYS format code with `dart format`** - CI checks formatting
- **Check analysis_options.yaml compliance** - project uses flutter_lints

## Common Tasks

### Repository Structure
```
flutter_dotenv/
├── lib/
│   ├── flutter_dotenv.dart     # Main library export
│   └── src/
│       ├── dotenv.dart         # Core DotEnv implementation
│       ├── parser.dart         # .env file parser
│       └── errors.dart         # Error definitions
├── test/
│   ├── dotenv_test.dart        # Main functionality tests
│   ├── parser_test.dart        # Parser-specific tests
│   ├── empty_env_test.dart     # Edge case tests
│   ├── .env                    # Test environment file
│   └── .env-override           # Test override file
├── example/                    # Complete Flutter example app
├── tool/                       # Development utilities
│   ├── fmt.sh                  # Code formatting script
│   ├── docs.sh                 # Documentation generation
│   └── release.sh              # Release automation
└── .github/workflows/          # CI/CD automation
    └── flutter-tests.yml       # Test pipeline
```

### Key Files to Monitor
- **Always check `lib/src/dotenv.dart`** when modifying core functionality
- **Always check `lib/src/parser.dart`** when modifying .env parsing logic
- **Always update tests in `test/`** when adding new features
- **Always check `example/lib/main.dart`** for usage patterns
- **Always check `pubspec.yaml`** when modifying dependencies

### Development Tools
```bash
# Format code (modern command - tool/fmt.sh uses deprecated dartfmt)
dart format lib/ test/ example/lib/

# Generate documentation (modern command - tool/docs.sh uses deprecated dartdoc)
dart doc
# Documentation will be in doc/api/index.html

# Release (tool/release.sh) - requires GH_KEY_ID environment variable
# Only use for official releases
```

### Common Debugging Steps
1. **If `flutter pub get` fails**: Check internet connectivity and pubspec.yaml syntax
2. **If tests fail**: Check test/.env files exist and have correct content
3. **If example app crashes**: Verify assets/.env files are properly declared in example/pubspec.yaml under assets section
4. **If analysis fails**: Check analysis_options.yaml and fix linting errors
5. **If build fails**: Ensure Flutter SDK version matches environment constraints (>=2.12.0-0 <4.0.0)
6. **If .env parsing fails**: Check for proper quotes, escape sequences, and variable substitution syntax
7. **If environment variables are null**: Verify .env file is in assets bundle and loadFromString() or load() was called
8. **If variable substitution doesn't work**: Check test/.env for examples - use \$VAR or \${VAR} syntax

### Performance Expectations
- **Dependency resolution**: 30-90 seconds for `flutter pub get`
- **Static analysis**: 10-30 seconds for `flutter analyze`
- **Test execution**: 30-60 seconds for `flutter test`
- **Example app build**: 60-180 seconds for first `flutter run`
- **Documentation generation**: 30-60 seconds for `dart doc`

**CRITICAL**: NEVER CANCEL these operations. They may appear to hang but are processing. Always set timeouts 2-3x the expected time.

### Critical Warnings and Common Pitfalls

**DO NOT**:
- Cancel `flutter pub get`, `flutter test`, or `flutter run` commands - they take significant time
- Use deprecated `dartfmt` command (use `dart format` instead)
- Use deprecated `dartdoc` command (use `dart doc` instead)
- Forget to declare .env files in pubspec.yaml assets section
- Put .env files in version control if they contain secrets (check .gitignore)
- Skip the `await dotenv.load()` call in main() - variables will be empty

**ALWAYS DO**:
- Set timeouts 2-3x longer than expected completion time
- Run `flutter pub get` after any pubspec.yaml changes
- Check that .env files exist in the correct paths (assets/ for example, test/ for tests)
- Validate .env syntax - no spaces around = signs, proper quotes for special characters
- Test both with and without .env files (use empty_env_test.dart as reference)

### Package Usage Patterns
```dart
// Basic usage pattern
import 'package:flutter_dotenv/flutter_dotenv.dart';

// In main.dart - basic loading
await dotenv.load(fileName: "assets/.env");

// Advanced loading with merging and overrides
await dotenv.load(
  fileName: "assets/.env",
  mergeWith: {
    'TEST_VAR': '5',
    'DEFAULT_SETTING': 'value',
  },
  overrideWithFiles: ["assets/.env.override"],
);

// Access variables
String apiKey = dotenv.env['API_KEY'] ?? 'default_key';
String dbUrl = dotenv.get('DATABASE_URL', fallback: 'localhost');

// Null-safe access
String? optionalValue = dotenv.maybeGet('OPTIONAL_KEY');
String valueWithFallback = dotenv.maybeGet('OPTIONAL_KEY', fallback: 'default') ?? 'fallback';

// Type conversions
int port = dotenv.getInt('PORT', fallback: 8080);
bool debug = dotenv.getBool('DEBUG', fallback: false);
double timeout = dotenv.getDouble('TIMEOUT', fallback: 30.0);

// For testing - load from string
dotenv.loadFromString(envString: File('test/.env').readAsStringSync());
```

### Testing Patterns
- **Always test with and without .env files** (see empty_env_test.dart)
- **Always test variable substitution** (FOO=$BAR patterns)
- **Always test override scenarios** (mergeWith and overrideWith parameters)
- **Always test type conversions** (getInt, getBool, getDouble)
- **Always test fallback values** for missing variables

## Emergency Recovery

**If Flutter/Dart installation is corrupted:**
```bash
# Reinstall Flutter (Linux)
sudo snap install flutter --classic
# OR manual install
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:/path/to/flutter/bin"
flutter doctor
```

**If dependencies are corrupted:**
```bash
flutter clean
flutter pub get
cd example/ && flutter clean && flutter pub get
```

**If tests are failing unexpectedly:**
```bash
# Check that test files exist
ls -la test/.env test/.env-override
# Verify test file content matches expected format
head test/.env
# Run individual test files
flutter test test/dotenv_test.dart --verbose
```

**If example app won't run:**
```bash
# Check assets are properly declared
grep -A5 "assets:" example/pubspec.yaml
# Verify .env files exist
ls -la example/assets/
# Clean and rebuild
cd example/ && flutter clean && flutter pub get && flutter run
```