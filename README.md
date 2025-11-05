# Darts Scorer Mobile App

A Flutter mobile application for tracking darts game scores with an interactive dartboard interface.

## Features

- **Interactive Dartboard**: Tap-based score recording with visual dartboard
- **Multiple Game Types**: Support for 501, 301, Cricket, and Around the Clock
- **Finish Detection**: Automatic checkout suggestions when you can finish
- **Multi-Player**: Track games with 2-4 players
- **Offline-First**: All data stored locally, no internet required
- **Statistics**: Track averages, checkout percentage, and turn history

## Tech Stack

- **Framework**: Flutter 3.24+
- **Language**: Dart 3.5+
- **State Management**: Provider
- **Storage**: SQLite (sqflite)
- **Testing**: flutter_test, mockito, golden_toolkit

## Prerequisites

1. **Flutter SDK 3.24+**
   - Install from: https://docs.flutter.dev/get-started/install
   - Verify: `flutter --version`

2. **Dart SDK 3.5+** (included with Flutter)

3. **Platform-Specific Tools**:
   - **iOS**: Xcode 14+ (macOS only)
   - **Android**: Android SDK, Android Studio

## Setup

```bash
# Install dependencies
flutter pub get

# Run on device/simulator
flutter run

# Run tests
flutter test

# Generate coverage
flutter test --coverage
```

## Project Structure

```
lib/
├── models/              # Data models (Game, Player, Turn, Dart)
├── services/
│   ├── game_engine/     # Core game logic
│   ├── scoring/         # Score calculation
│   ├── checkout/        # Finish detection
│   └── persistence/     # Database & repositories
├── ui/
│   ├── screens/         # Full screen views
│   ├── components/      # Reusable widgets
│   └── theme/           # App theme
└── utils/               # Helpers and constants

test/
├── contract/            # API contract tests
├── integration/         # E2E tests
└── unit/                # Unit tests
```

## Development

This project follows **Test-Driven Development (TDD)** principles:
1. Write tests first
2. Watch them fail (red)
3. Implement to make them pass (green)
4. Refactor while keeping tests green

## Documentation

See `/specs/001-darts-score-tracker/` for:
- `spec.md` - Feature specification
- `plan.md` - Technical implementation plan
- `data-model.md` - Database schema
- `contracts/` - API specifications
- `tasks.md` - Implementation task list
- `quickstart.md` - Developer guide

## License

Copyright © 2025 Darts Scorer
