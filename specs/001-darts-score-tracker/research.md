# Technology Research: Darts Score Tracker Mobile App

**Feature**: 001-darts-score-tracker
**Date**: 2025-10-23
**Research Phase**: Phase 0

## Executive Summary

This document captures the technology decisions and research for building a cross-platform mobile darts scoring application. The chosen stack is **Flutter/Dart** with **SQLite** persistence, providing optimal support for custom UI rendering (dartboard), offline-first functionality, and cross-platform deployment to iOS and Android.

## Platform Selection

### Requirements Analysis

The feature specification demands:
1. **Custom visual dartboard UI** with precise touch zone detection
2. **Offline-first** operation (no network dependency)
3. **Cross-platform** mobile support (iOS + Android)
4. **High performance** UI (60fps, <100ms tap response)
5. **Local data persistence** with relational queries
6. **Complex game logic** with multiple rule sets

### Technology Decision: Flutter/Dart

**Selected**: Flutter 3.24+ with Dart 3.5+

**Rationale**:
- **Custom painting**: Flutter's `CustomPaint` widget provides low-level canvas API perfect for dartboard rendering
- **Cross-platform**: Single codebase for iOS and Android with native performance
- **Touch handling**: Built-in gesture detection with precise coordinate mapping
- **Performance**: Dart compiles to native ARM code, achieving 60fps easily
- **Developer experience**: Hot reload, strong type system, excellent tooling
- **Offline-first**: No network dependency, runs entirely on device
- **Mature ecosystem**: Extensive widget library, proven in production apps

**Alternatives Considered**:

| Alternative | Pros | Cons | Rejection Reason |
|------------|------|------|------------------|
| React Native | Large community, JavaScript | Requires bridge for custom rendering, performance overhead | Custom dartboard painting less performant |
| Native Swift/Kotlin | Maximum performance, platform APIs | Duplicate codebase, 2x development time | Not worth 2x effort for this use case |
| Progressive Web App (PWA) | No installation, web standards | Limited offline, no custom painting performance | Canvas API too slow for smooth dartboard |
| Xamarin/MAUI | C# ecosystem | Smaller community, uncertain future | Flutter more proven for custom UI |

## State Management

### Requirements Analysis

State management needs:
- Track current game state (scores, turns, players)
- Update UI reactively when scores change
- Persist state across app lifecycle
- Support undo/redo operations
- Moderate complexity (not enterprise-scale)

### Technology Decision: Provider

**Selected**: Provider 6.1+

**Rationale**:
- **Official recommendation**: Flutter team's recommended approach
- **Simple mental model**: InheritedWidget wrapper, easy to understand
- **Performance**: Minimal overhead, only rebuilds affected widgets
- **Type-safe**: Compile-time safety with generic types
- **Testing**: Easy to mock providers in tests
- **Right-sized**: Not overkill for this app's complexity

**Alternatives Considered**:

| Alternative | Pros | Cons | Rejection Reason |
|------------|------|------|------------------|
| Riverpod | More features, better testing | Steeper learning curve, overkill | Provider sufficient for our needs |
| BLoC | Structured pattern, RxDart | Heavy boilerplate, reactive complexity | Too complex for simple state |
| GetX | All-in-one solution | Magic, hard to debug, non-standard | Violates simplicity principle |
| setState | Built-in, simple | Poor scalability, prop drilling | Insufficient for multi-screen state |

## Data Persistence

### Requirements Analysis

Persistence needs:
- Store game history with relational structure
- Query players, turns, and darts efficiently
- Support migrations as schema evolves
- Offline-first (no network)
- Mobile-optimized (low memory, fast startup)

### Technology Decision: SQLite (via sqflite)

**Selected**: sqflite 2.3+

**Rationale**:
- **Relational model**: Perfect fit for Game → Player → Turn → Dart hierarchy
- **Performance**: C-based SQLite is extremely fast on mobile
- **Proven**: Industry standard, used by millions of apps
- **Query power**: SQL for complex queries (stats, filtering, aggregation)
- **Migration support**: Version-based schema migrations
- **Zero config**: No server, no setup, embedded database
- **Small footprint**: Minimal size and memory impact

**Alternatives Considered**:

| Alternative | Pros | Cons | Rejection Reason |
|------------|------|------|------------------|
| Hive | Fast, pure Dart | No relations, manual indexing | Poor fit for relational data |
| Isar | Very fast, good DX | Newer, less proven, larger binary | SQLite more battle-tested |
| Shared Preferences | Simple API | Key-value only, no queries | Insufficient for structured data |
| ObjectBox | Fast, reactive | Commercial licensing, overkill | SQLite simpler and free |
| Firebase/Cloud | Sync, backup | Network required, privacy concerns | Must be offline-first |

## UI Rendering

### Requirements Analysis

UI rendering needs:
- Custom dartboard with 82+ touch zones (20 numbers × 3 multipliers + 2 bulls)
- Precise touch coordinate → zone mapping
- Visual feedback on tap
- Smooth animations
- Support rotation/scaling
- Minimum 7mm touch targets (accessibility)

### Technology Decision: CustomPaint + GestureDetector

**Selected**: Flutter's built-in CustomPaint widget with Canvas API

**Rationale**:
- **Full control**: Low-level drawing API for exact dartboard layout
- **Performance**: Hardware-accelerated rendering via Skia
- **Touch mapping**: GestureDetector provides tap coordinates, convert to polar coordinates
- **Flexibility**: Can adjust zone sizes for accessibility
- **Testable**: Can verify zone calculations in unit tests
- **Standard**: No external dependencies needed

**Implementation approach**:
1. **DartboardPainter** extends CustomPainter
2. Paint dartboard zones in layers (doubles → triples → singles → bulls)
3. Use polar coordinates (radius, angle) for zone layout
4. GestureDetector captures tap coordinates (x, y)
5. Convert Cartesian (x, y) → Polar (r, θ) to determine zone
6. Provide visual feedback with setState animation

**Alternatives Considered**:

| Alternative | Pros | Cons | Rejection Reason |
|------------|------|------|------------------|
| SVG (flutter_svg) | Vector graphics, scalable | No touch mapping, static only | Can't handle dynamic interaction |
| Image map | Simple to create | Pixelated when scaled, large file | Poor UX on different screen sizes |
| Pre-built widget library | Fast development | No suitable dartboard widget exists | Would have to build anyway |
| HTML Canvas (WebView) | Familiar web tech | Poor performance, non-native | Flutter CustomPaint is native |

## Checkout Calculation

### Requirements Analysis

Checkout calculation needs:
- Find valid dart combinations to reach exactly 0 from score 2-170
- Enforce "must finish on double" rule
- Show multiple checkout options when available
- Calculate quickly (<1 second)
- Handle impossible finishes (e.g., score of 1, 169, etc.)

### Technology Decision: Pre-computed Checkout Database

**Selected**: Static checkout table with algorithmic fallback

**Rationale**:
- **Performance**: O(1) lookup for common scores
- **Completeness**: Can compute all 2-170 checkouts once
- **Size**: ~500 entries × 20 bytes = ~10KB (negligible)
- **Quality**: Hand-verify optimal checkout paths for common scores
- **Fallback**: Algorithm can compute rare/edge cases on demand

**Implementation approach**:
1. Create `checkout_database.dart` with Map<int, List<CheckoutSuggestion>>
2. Pre-populate with verified checkouts for scores 2-170
3. CheckoutCalculator queries database first
4. If not found (edge case), run brute-force search:
   - Try all valid 1-dart finishes
   - Try all valid 2-dart finishes
   - Try all valid 3-dart finishes
5. Cache computed results for session

**Data structure**:
```dart
class CheckoutSuggestion {
  final int score;
  final List<Dart> darts;
  final String description; // e.g., "D20" or "T20-D20"
  final int difficulty; // 1-5 rating for ordering
}
```

**Alternatives Considered**:

| Alternative | Pros | Cons | Rejection Reason |
|------------|------|------|------------------|
| Pure algorithm | Dynamic, handles all cases | Slow for real-time use | Pre-compute is faster |
| API call | Always up-to-date | Network required, latency | Must be offline |
| Machine learning | Could learn optimal paths | Overkill, training overhead | Deterministic problem |
| Hardcoded strings | Simple | Not structured, hard to test | Need data model for UI |

## Testing Strategy

### Requirements Analysis

Testing needs:
- Verify game rules (501, 301, Cricket, Around the Clock)
- Validate scoring calculations
- Test checkout detection
- Ensure UI responds correctly
- Verify multi-player turn rotation
- Test persistence/recovery

### Technology Decision: flutter_test + mockito

**Selected**: flutter_test (built-in) + mockito 5.4+ for mocking

**Test types**:

#### 1. Contract Tests (`test/contract/`)
Verify public API contracts for each service:
- `game_engine_test.dart`: Test GameEngine interface
- `checkout_calculator_test.dart`: Test CheckoutCalculator interface
- `persistence_test.dart`: Test DatabaseService interface

#### 2. Integration Tests (`test/integration/`)
Test user journeys end-to-end:
- `game_flow_test.dart`: Complete game from start to finish
- `multi_player_test.dart`: Multi-player turn rotation
- `checkout_detection_test.dart`: Finish detection and suggestions

#### 3. Unit Tests (`test/unit/`)
Test individual functions and classes:
- `models/`: Model validation and serialization
- `services/`: Business logic (rules, validators, calculators)
- `widgets/`: Widget behavior and rendering

**Rationale**:
- **flutter_test**: Built-in, zero setup, widget testing support
- **mockito**: Type-safe mocking for isolating dependencies
- **Integration tests**: Validate acceptance criteria from spec.md
- **TDD approach**: Write tests first per Constitution Principle II

**Alternatives Considered**:

| Alternative | Pros | Cons | Rejection Reason |
|------------|------|------|------------------|
| integration_test only | Real E2E tests | Slow, brittle, hard to debug | Need unit tests too |
| Manual testing only | Feels "real" | Not repeatable, no regression safety | Violates TDD principle |
| mocktail | Newer, different API | Less mature than mockito | mockito is proven |

## Dependencies Summary

### Production Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management
  provider: ^6.1.0

  # Persistence
  sqflite: ^2.3.0
  path: ^1.8.3  # For database path construction

  # UI (if needed for icons/assets)
  flutter_svg: ^2.0.0  # For SVG assets/icons

  # Settings persistence
  shared_preferences: ^2.2.0
```

### Development Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code generation for mocks
  mockito: ^5.4.0
  build_runner: ^2.4.0

  # Linting
  flutter_lints: ^3.0.0

  # Integration testing
  integration_test:
    sdk: flutter
```

### Rationale for Each Dependency

- **provider**: Official state management (see State Management section)
- **sqflite**: Mobile SQLite (see Data Persistence section)
- **path**: Required for sqflite database file paths
- **flutter_svg**: For scalable icons/graphics (minimal, may remove if unused)
- **shared_preferences**: For app settings (game defaults, user preferences)
- **mockito**: Mocking for unit tests (see Testing Strategy section)
- **build_runner**: Required for mockito code generation
- **flutter_lints**: Official linting rules for code quality
- **integration_test**: Flutter's E2E testing framework

## Platform-Specific Considerations

### iOS (12+)

- **Minimum version**: iOS 12 (Flutter 3.24 requirement)
- **Testing devices**: iPhone SE (small screen), iPhone 14 (large screen), iPad (tablet)
- **Permissions**: None required (no camera, location, etc.)
- **App Store**: Standard approval process
- **Considerations**:
  - Test dartboard sizing on various screen sizes
  - Ensure touch targets meet Apple HIG (44pt minimum)
  - Test in both portrait and landscape

### Android (6.0+, API 23+)

- **Minimum version**: Android 6.0 Marshmallow (API 23)
- **Testing devices**: Small phone (5"), medium phone (6"), tablet (10")
- **Permissions**: None required in manifest
- **Play Store**: Standard approval process
- **Considerations**:
  - Test on various screen densities (mdpi, hdpi, xhdpi, xxhdpi)
  - Ensure touch targets meet Material Design (48dp minimum)
  - Test back button behavior (should exit gracefully)
  - Test on different Android versions (6, 9, 12, 14)

### Shared Considerations

- **Orientation**: Support both portrait and landscape
- **Screen sizes**: 4.7" (iPhone SE) to 12.9" (iPad Pro)
- **Touch targets**: Minimum 7mm physical size (~44pt/48dp)
- **Dark mode**: Consider adding dark theme support
- **Accessibility**: Support system font scaling
- **Interruptions**: Handle phone calls, notifications gracefully
- **Battery**: Avoid keeping screen on unnecessarily

## Performance Targets

### Measurement Approach

Will use Flutter DevTools to measure:

1. **Frame rendering**: Target 60fps (16.67ms per frame)
   - Monitor during dartboard interactions
   - Use timeline to identify jank

2. **Tap response**: Target <100ms from tap to UI update
   - Measure in GestureDetector onTapDown → setState → build cycle
   - Should feel instantaneous to user

3. **Checkout calculation**: Target <1s for score update
   - Measure CheckoutCalculator.findCheckouts() duration
   - Use database lookup (should be <10ms) vs algorithm

4. **App startup**: Target <2s cold start
   - Measure main() → first frame rendered
   - Optimize database initialization if needed

5. **Memory**: Target <100MB peak usage
   - Monitor during extended gameplay
   - Watch for memory leaks in long sessions

### Optimization Strategy

- **Measure first**: No premature optimization
- **Profile in release mode**: Debug mode is slower
- **Use const widgets**: Reduce rebuilds
- **Optimize dartboard painting**: Cache Paint objects
- **Lazy load**: Don't load full game history on startup
- **Database indexes**: Index frequently queried columns

## Security & Privacy

### Data Security

- **Local only**: All data stored on device (SQLite)
- **No network**: No data transmission
- **No analytics**: No user tracking
- **No authentication**: Single-user app

### Privacy Considerations

- **Player names**: Stored locally, never transmitted
- **Game history**: Retained 30 days, then auto-deleted
- **No PII**: No email, phone, or personal data collected
- **No permissions**: App requests no system permissions

### GDPR/Privacy Compliance

- **Data controller**: User owns their data
- **Right to deletion**: User can clear game history
- **Data portability**: Could export SQLite database (future feature)
- **No third parties**: No data sharing

## Migration & Versioning Strategy

### Database Migrations

Using sqflite's `onUpgrade` callback:

```dart
Future<Database> _initDatabase() async {
  return await openDatabase(
    path,
    version: 1,  // Increment on schema changes
    onCreate: _onCreate,
    onUpgrade: _onUpgrade,
  );
}

Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
  // Run migrations sequentially
  if (oldVersion < 2) {
    await db.execute('ALTER TABLE games ADD COLUMN ...');
  }
  if (oldVersion < 3) {
    await db.execute('CREATE INDEX ...');
  }
}
```

### App Versioning

Following semantic versioning (MAJOR.MINOR.PATCH):

- **MAJOR**: Breaking changes (rare)
- **MINOR**: New features (game types, statistics)
- **PATCH**: Bug fixes, performance improvements

### Backwards Compatibility

- Maintain database compatibility across MINOR versions
- Provide migration path for MAJOR version changes
- Test upgrades from v1.0 → v2.0 before release

## Open Questions & Future Research

### Questions to Resolve

1. **Dartboard zone sizing**: What's the optimal zone size for 5" vs 6" vs tablet screens?
   - **Action**: Prototype and user test with various finger sizes

2. **Checkout ordering**: How to prioritize multiple valid checkouts?
   - **Action**: Research player preferences, potentially add difficulty ratings

3. **Statistics scope**: What stats are most valuable to players?
   - **Action**: Start with basics (average, checkout %), add more in v2

4. **Game history retention**: Is 30 days the right balance?
   - **Action**: Monitor storage usage, make configurable if needed

### Future Enhancements (Out of Scope)

- **Cloud sync**: Backup games across devices
- **Multiplayer**: Real-time scoring with friends remotely
- **Advanced stats**: Heat maps, trends, skill progression
- **Practice mode**: Training exercises for specific finishes
- **Camera integration**: Auto-detect dart positions (computer vision)

## Conclusion

The chosen technology stack (Flutter/Dart + SQLite + Provider) optimally balances:

- **Cross-platform**: Single codebase for iOS and Android
- **Performance**: Native rendering, fast database, smooth UI
- **Offline-first**: No network dependency
- **Custom UI**: Full control over dartboard rendering
- **Simplicity**: Standard tools, minimal dependencies
- **Maintainability**: Well-understood patterns, good tooling

This stack aligns with all constitutional principles and provides a solid foundation for building a high-quality mobile darts scoring app.

---

**Research completed**: 2025-10-23
**Next phase**: Phase 1 - Design (data-model.md, contracts/, quickstart.md)
