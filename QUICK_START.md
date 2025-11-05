# Darts Scorer - Quick Start Guide

## Installation

### Prerequisites
- Flutter SDK 3.24+
- Dart SDK 3.5+
- Android Studio / Xcode (for mobile development)

### Setup
```bash
# Clone the repository (if from git)
git clone <repository-url>
cd darts_scorer

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Project Structure

```
darts_scorer/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   ├── providers/                # State management
│   ├── services/                 # Business logic
│   │   ├── game_engine/          # Game rules and logic
│   │   ├── persistence/          # Database operations
│   │   ├── checkout_calculator/  # Checkout logic
│   │   └── statistics/           # Stats calculation
│   └── ui/                       # User interface
│       ├── screens/              # Full screens
│       ├── widgets/              # Reusable widgets
│       └── theme/                # App theming
├── test/                         # Tests
│   ├── unit/                     # Unit tests
│   ├── integration/              # Integration tests
│   └── test_helpers/             # Test utilities
├── pubspec.yaml                  # Dependencies
└── README.md                     # Documentation
```

## Features

### Game Types
1. **501** - Classic countdown, double-out
2. **301** - Shorter countdown, double-out
3. **Cricket** - Mark-based scoring (15-20, bulls)
4. **Around the Clock** - Sequential 1-20, bullseye

### Multi-Player
- Support for 1-4 players
- Turn rotation
- Individual statistics
- Player highlighting

### UI Features
- Visual dartboard interface
- Finish detection with checkout suggestions
- Bust detection
- Win celebration
- Game history
- Settings (theme, haptic, sound)
- Light/Dark mode

## Usage

### Starting a New Game
1. Launch app
2. Tap "New Game"
3. Select game type (501, 301, Cricket, Around the Clock)
4. Enter player names (1-4 players)
5. Tap "Start Game"

### Playing
1. Tap dartboard zones to record darts
2. Complete turn after 3 darts (or less)
3. Watch for finish detection indicators
4. Undo last dart if needed
5. Win by reaching exact 0 on a double (501/301)

### Settings
- Access via home screen settings icon
- Toggle haptic feedback
- Toggle sound effects
- Select theme (Light/Dark/System)

### History
- Access via home screen history icon
- View completed games
- See winners and dates
- Delete old games

## Development

### Running Tests
```bash
# All tests
flutter test

# Specific test
flutter test test/unit/services/finish_detection_test.dart

# With coverage
flutter test --coverage
```

### Code Analysis
```bash
flutter analyze
```

### Formatting
```bash
flutter format lib/ test/
```

## Building

### Debug Build
```bash
flutter build apk --debug
```

### Release Build
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Architecture

### State Management
- **Provider pattern** for reactive state
- **GameProvider** manages game state
- **SettingsProvider** manages app settings

### Data Layer
- **SQLite** database via sqflite
- **Repository pattern** for data access
- **Models** for type-safe data structures

### Business Logic
- **GameEngine** orchestrates game flow
- **GameRule** interface for different game types
- **CheckoutCalculator** for finish detection
- **StatsCalculator** for player statistics

## Key Files

### Core
- `lib/main.dart` - App initialization
- `lib/providers/game_provider.dart` - Game state management
- `lib/services/game_engine/game_engine.dart` - Game orchestration

### Game Rules
- `lib/services/game_engine/rules/five_oh_one_rule.dart`
- `lib/services/game_engine/rules/three_oh_one_rule.dart`
- `lib/services/game_engine/rules/cricket_rule.dart`
- `lib/services/game_engine/rules/around_clock_rule.dart`

### UI Screens
- `lib/ui/screens/home_screen.dart` - Home/menu
- `lib/ui/screens/game_setup_screen.dart` - Game configuration
- `lib/ui/screens/game_screen.dart` - Active game
- `lib/ui/screens/history_screen.dart` - Game history
- `lib/ui/screens/settings_screen.dart` - App settings

### Key Widgets
- `lib/ui/widgets/dartboard/dartboard_widget.dart` - Interactive dartboard
- `lib/ui/widgets/checkout_panel.dart` - Finish detection UI
- `lib/ui/widgets/player_card.dart` - Player info display
- `lib/ui/widgets/cricket_score_display.dart` - Cricket scorecard

## Troubleshooting

### Tests Failing on Desktop
- Tests require SQLite FFI library
- Install: `sudo apt-get install libsqlite3-dev` (Linux)
- Tests will work on mobile devices/emulators

### Build Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Database Issues
- Database is automatically created on first run
- Delete app data to reset database
- Location: App data directory (platform-specific)

## Performance Tips

1. **Dartboard Rendering**
   - Uses CustomPainter for efficiency
   - Consider RepaintBoundary for optimization

2. **Database Queries**
   - Indexed on frequently queried columns
   - Use pagination for large datasets

3. **State Management**
   - Provider notifies only when state changes
   - Use const constructors where possible

## Contributing

### Code Style
- Follow Dart style guide
- Use flutter format before committing
- Run flutter analyze to check for issues

### Testing
- Write tests for new features
- Maintain test coverage
- Test on both Android and iOS

### Pull Requests
- One feature per PR
- Include tests
- Update documentation

## Support

### Documentation
- README.md - Project overview
- IMPLEMENTATION_COMPLETE.md - Implementation details
- IMPLEMENTATION_SUMMARY.md - Comprehensive summary
- QUICK_START.md - This file

### Issues
- Check existing issues
- Provide reproduction steps
- Include Flutter version, platform, device info

## License

See LICENSE file for details.

## Version History

### 1.0.0 (2025-10-23)
- Initial release
- 4 game types supported
- Multi-player (1-4 players)
- Full statistics
- Theme support
- Game history

---

**Status**: Production Ready ✅
**Last Updated**: 2025-10-23
