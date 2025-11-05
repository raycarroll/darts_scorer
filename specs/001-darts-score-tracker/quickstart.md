# Quickstart Guide: Darts Score Tracker

**Feature**: 001-darts-score-tracker
**Date**: 2025-10-23

## Overview

This guide will get you up and running with the Darts Score Tracker development environment in under 10 minutes.

## Prerequisites

### Required Software

1. **Flutter SDK 3.24+**
   - Download: https://docs.flutter.dev/get-started/install
   - Verify: `flutter --version`

2. **Dart SDK 3.5+** (included with Flutter)
   - Verify: `dart --version`

3. **IDE** (choose one):
   - **VS Code** with Flutter extension (recommended for beginners)
   - **Android Studio** with Flutter plugin (recommended for Android dev)
   - **IntelliJ IDEA** with Flutter plugin

4. **Platform SDKs**:
   - **For iOS development** (macOS only):
     - Xcode 15+
     - CocoaPods: `sudo gem install cocoapods`
   - **For Android development**:
     - Android Studio
     - Android SDK (API level 23+)
     - Android Emulator or physical device

### System Requirements

- **macOS**: 10.15+ (for iOS development)
- **Linux**: Ubuntu 20.04+ or equivalent
- **Windows**: Windows 10+ (Android only)
- **RAM**: 8GB minimum, 16GB recommended
- **Disk**: 5GB free space for Flutter SDK + tools

## Setup Instructions

### 1. Install Flutter

**macOS/Linux**:
```bash
# Download Flutter
git clone https://github.com/flutter/flutter.git -b stable ~/flutter

# Add to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="$PATH:$HOME/flutter/bin"

# Verify installation
flutter doctor
```

**Windows**:
```powershell
# Download Flutter from https://docs.flutter.dev/get-started/install/windows
# Extract to C:\src\flutter

# Add to PATH via System Properties > Environment Variables
# Add: C:\src\flutter\bin

# Verify installation
flutter doctor
```

### 2. Run Flutter Doctor

```bash
flutter doctor
```

Fix any issues indicated by `flutter doctor`. Common fixes:

- **Android licenses**: `flutter doctor --android-licenses`
- **Xcode setup**: Open Xcode and accept license
- **CocoaPods**: `sudo gem install cocoapods`

### 3. Clone Repository

```bash
git clone <repository-url>
cd darts_scorer
git checkout 001-darts-score-tracker
```

### 4. Install Dependencies

```bash
# Get Flutter packages
flutter pub get

# Verify no issues
flutter pub outdated
```

### 5. Setup IDE

**VS Code**:
1. Install "Flutter" extension
2. Install "Dart" extension (auto-installed with Flutter)
3. Open project: `code .`
4. Recommended settings (`.vscode/settings.json`):
   ```json
   {
     "dart.flutterSdkPath": "/path/to/flutter",
     "dart.lineLength": 100,
     "editor.formatOnSave": true,
     "editor.rulers": [100]
   }
   ```

**Android Studio**:
1. Install "Flutter" plugin (Preferences > Plugins)
2. Install "Dart" plugin (auto-installed with Flutter)
3. Open project: File > Open > select `darts_scorer/`
4. Trust Gradle project when prompted

### 6. Run on Emulator/Simulator

**iOS Simulator** (macOS only):
```bash
# Open iOS Simulator
open -a Simulator

# Run app
flutter run
```

**Android Emulator**:
```bash
# List available devices
flutter devices

# Create emulator if needed (via Android Studio > AVD Manager)

# Run app
flutter run
```

**Physical Device**:
- **iOS**: Connect iPhone, trust computer, `flutter run`
- **Android**: Enable USB debugging, connect device, `flutter run`

### 7. Verify Installation

Run the test suite to ensure everything is working:

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/models/game_test.dart

# Run with coverage
flutter test --coverage
```

## Project Structure Overview

```
darts_scorer/
├── lib/                        # Source code
│   ├── main.dart              # App entry point
│   ├── models/                # Data models
│   ├── services/              # Business logic
│   ├── ui/                    # User interface
│   ├── providers/             # State management
│   └── utils/                 # Utilities
├── test/                      # Tests
│   ├── contract/              # Contract tests
│   ├── integration/           # Integration tests
│   └── unit/                  # Unit tests
├── android/                   # Android platform code
├── ios/                       # iOS platform code
├── pubspec.yaml               # Dependencies
└── README.md                  # Project README
```

## Development Workflow

### 1. Run App in Development Mode

```bash
# Run with hot reload
flutter run

# Run on specific device
flutter run -d <device-id>

# Run in debug mode (default)
flutter run --debug

# Run in profile mode (performance testing)
flutter run --profile

# Run in release mode (production build)
flutter run --release
```

**Hot Reload**: Press `r` in terminal while app is running to hot reload changes.
**Hot Restart**: Press `R` to fully restart app with new changes.

### 2. Run Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/models/game_test.dart

# Run tests with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 3. Analyze Code

```bash
# Run static analysis
flutter analyze

# Fix auto-fixable issues
dart fix --apply

# Format code
dart format lib/ test/
```

### 4. Build for Production

**Android APK**:
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Android App Bundle** (for Play Store):
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**iOS App** (macOS only):
```bash
flutter build ios --release
# Output: build/ios/iphoneos/Runner.app
# Open in Xcode for archiving: open ios/Runner.xcworkspace
```

## Common Commands

### Package Management

```bash
# Install dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Check for outdated packages
flutter pub outdated

# Add new dependency
flutter pub add <package_name>

# Add dev dependency
flutter pub add --dev <package_name>
```

### Code Generation

```bash
# Generate mocks for testing
flutter pub run build_runner build

# Watch for changes and auto-generate
flutter pub run build_runner watch

# Clean generated files
flutter pub run build_runner clean
```

### Device Management

```bash
# List connected devices
flutter devices

# List emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator-id>
```

### Cleaning

```bash
# Clean build artifacts
flutter clean

# Re-fetch packages
flutter pub get

# Full clean (includes pods on iOS)
flutter clean && rm -rf ios/Pods ios/Podfile.lock && flutter pub get
```

## Debugging

### VS Code Debugging

1. Set breakpoints by clicking left of line numbers
2. Press `F5` to start debugging
3. Use debug console for inspection
4. Step through code with `F10` (step over), `F11` (step into)

### Android Studio Debugging

1. Set breakpoints by clicking left gutter
2. Click "Debug" button or `Shift+F9`
3. Use "Variables" panel to inspect state
4. Use "Evaluate Expression" (`Alt+F8`) to test code

### Flutter DevTools

```bash
# Run app with --observatory-port
flutter run --observatory-port=9200

# Open DevTools in browser
dart devtools

# Or use built-in command
flutter pub global activate devtools
flutter pub global run devtools
```

**DevTools features**:
- **Flutter Inspector**: Widget tree visualization
- **Timeline**: Performance profiling
- **Memory**: Heap snapshots and leak detection
- **Network**: HTTP request monitoring
- **Logging**: View app logs

## Testing Strategy

### Running Tests by Type

```bash
# Unit tests only
flutter test test/unit/

# Integration tests only
flutter test test/integration/

# Contract tests only
flutter test test/contract/

# Widget tests
flutter test --plain-name "widget"
```

### Test-Driven Development (TDD)

Per project constitution, follow TDD workflow:

1. **Write test first**:
   ```dart
   test('recordDart updates score correctly', () {
     // Arrange
     final game = Game(/* ... */);

     // Act
     final result = gameEngine.recordDart(/* ... */);

     // Assert
     expect(result.score, equals(441));
   });
   ```

2. **Run test - verify failure** (RED):
   ```bash
   flutter test test/unit/services/game_engine_test.dart
   # Should fail - method not implemented yet
   ```

3. **Implement minimal code** (GREEN):
   ```dart
   Future<GameState> recordDart({...}) async {
     // Minimal implementation to make test pass
     return GameState(score: 441);
   }
   ```

4. **Run test - verify pass**:
   ```bash
   flutter test test/unit/services/game_engine_test.dart
   # Should pass now
   ```

5. **Refactor** (REFACTOR):
   - Clean up code while keeping tests green
   - Extract methods, rename variables, improve clarity

### Coverage Requirements

- **Target**: 90%+ overall coverage
- **Critical paths**: 100% coverage (game rules, scoring, finish detection)
- **View coverage**:
  ```bash
  flutter test --coverage
  genhtml coverage/lcov.info -o coverage/html
  open coverage/html/index.html
  ```

## Database Management

### SQLite Database Location

**Android**:
```
/data/data/com.example.darts_scorer/databases/darts_scorer.db
```

**iOS**:
```
~/Library/Developer/CoreSimulator/Devices/{DEVICE_ID}/data/Containers/Data/Application/{APP_ID}/Documents/darts_scorer.db
```

### Inspecting Database

```bash
# Pull database from Android device
adb pull /data/data/com.example.darts_scorer/databases/darts_scorer.db

# Open with sqlite3
sqlite3 darts_scorer.db

# List tables
.tables

# Query data
SELECT * FROM games;
SELECT * FROM players WHERE game_id = 'game-001';

# Exit
.quit
```

### Resetting Database

```bash
# Delete app data (Android)
adb shell pm clear com.example.darts_scorer

# Delete app and reinstall (iOS)
flutter run --uninstall-first
```

## Troubleshooting

### Common Issues

#### "Could not find an option named 'observatory-port'"
**Solution**: Update Flutter to latest stable:
```bash
flutter upgrade
flutter doctor
```

#### "Gradle build failed"
**Solution**: Clean and rebuild:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

#### "CocoaPods not installed"
**Solution**: Install CocoaPods:
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
flutter run
```

#### "No devices found"
**Solution**:
- Android: Enable USB debugging in Developer Options
- iOS: Trust computer on device
- Check `flutter devices`

#### "PlatformException: DatabaseException"
**Solution**: Reset database:
```bash
flutter run --uninstall-first
```

### Getting Help

- **Flutter Docs**: https://docs.flutter.dev
- **Dart Docs**: https://dart.dev/guides
- **Stack Overflow**: Tag `flutter` or `dart`
- **GitHub Issues**: Report bugs in project repository
- **Flutter Discord**: https://discord.gg/flutter

## Next Steps

Now that your environment is set up:

1. **Read the spec**: `specs/001-darts-score-tracker/spec.md`
2. **Review the plan**: `specs/001-darts-score-tracker/plan.md`
3. **Study contracts**: `specs/001-darts-score-tracker/contracts/`
4. **Check tasks**: `specs/001-darts-score-tracker/tasks.md` (when generated)
5. **Start with tests**: Begin TDD cycle with P1 user stories

## Development Best Practices

### Code Style

Follow official Dart style guide:
```bash
# Auto-format
dart format lib/ test/

# Check lints
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

### Git Workflow

```bash
# Create feature branch
git checkout -b feature/dartboard-widget

# Make changes, commit frequently
git add .
git commit -m "Add dartboard custom painter"

# Push to remote
git push origin feature/dartboard-widget

# Create pull request on GitHub
```

### Code Review Checklist

Before submitting PR:
- [ ] All tests pass: `flutter test`
- [ ] No lint errors: `flutter analyze`
- [ ] Code formatted: `dart format .`
- [ ] Coverage maintained: `flutter test --coverage`
- [ ] Manual testing on iOS and Android
- [ ] Updated documentation if needed

## Performance Profiling

### Measuring Frame Rate

```bash
# Run in profile mode
flutter run --profile

# Open DevTools
# Monitor "Performance" tab
# Look for frames > 16ms (jank)
```

### Measuring App Size

```bash
# Build release APK
flutter build apk --release --analyze-size

# Build iOS
flutter build ios --release --analyze-size
```

### Memory Profiling

1. Run app: `flutter run --profile`
2. Open DevTools: `dart devtools`
3. Navigate to "Memory" tab
4. Take heap snapshots before/after actions
5. Look for memory leaks (objects not garbage collected)

---

**Last updated**: 2025-10-23
**Questions?** Open an issue or consult the spec documentation.
