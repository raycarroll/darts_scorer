# Implementation Plan: Darts Score Tracker Mobile App

**Branch**: `001-darts-score-tracker` | **Date**: 2025-10-23 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-darts-score-tracker/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

A mobile darts scoring application with visual dartboard interface for recording scores by tapping zones, supporting multiple game types (501, 301, Cricket, Around the Clock), multi-player functionality, finish detection, and checkout suggestions. Built with Flutter/Dart for cross-platform mobile deployment with offline-first architecture and SQLite persistence.

## Technical Context

**Language/Version**: Dart 3.5+ / Flutter 3.24+
**Primary Dependencies**: Flutter SDK, sqflite (^2.3.0), provider (^6.1.0), flutter_svg (^2.0.0), shared_preferences (^2.2.0)
**Storage**: SQLite (via sqflite) for game data, SharedPreferences for app settings
**Testing**: flutter_test (unit/widget tests), integration_test (E2E tests), mockito (^5.4.0) for mocking
**Target Platform**: iOS 12+ and Android 6.0+ (API level 23+)
**Project Type**: Mobile (single Flutter project with standard structure)
**Performance Goals**: 60 fps UI rendering, <100ms dartboard tap response, <1s checkout calculation
**Constraints**: Offline-capable, <50MB installed size, <100MB peak memory, touch precision for 7mm dartboard zones
**Scale/Scope**: Single-player + 2-4 player games, ~20 screens/views, 30-day local game history, checkout database for scores 2-170

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### ✅ I. Modular Component Design
- **Compliance**: Feature will be implemented with clear module boundaries:
  - `GameEngine` module: Core game logic and rules
  - `ScoreCalculator` module: Scoring calculations and validation
  - `CheckoutService` module: Finish detection and suggestions
  - `PersistenceService` module: Database operations
  - `DartboardUI` module: Visual dartboard widget
- **Interface contracts**: All modules will have documented public APIs in `contracts/` directory
- **Independence**: Each module can be tested and developed in isolation

### ✅ II. Test-First Development (TDD)
- **Compliance**: Tests will be written first for all user stories (P1-P4)
- **User approval**: Test scenarios defined in spec.md acceptance criteria will be validated before implementation
- **Test hierarchy**: Contract tests → Integration tests → Unit tests
- **Coverage**: Target 90%+ code coverage with focus on critical paths (scoring, finish detection, game rules)

### ✅ III. Clear Contracts & Interfaces
- **Compliance**: All module boundaries documented in `contracts/` directory
- **API contracts**: `game_engine_api.md`, `checkout_calculator_api.md`, `persistence_api.md`
- **Data contracts**: Complete data model in `data-model.md`
- **Behavior contracts**: Game type rules and validation logic explicitly documented

### ✅ IV. Simplicity & Maintainability
- **Compliance**: Using Flutter's standard architecture patterns (Provider for state, standard widget tree)
- **YAGNI**: Only implementing 4 game types specified (501, 301, Cricket, Around the Clock)
- **Boring solutions**: SQLite for storage (well-understood), Provider for state (Flutter standard)
- **No premature optimization**: Will measure performance before optimizing dartboard rendering

### ✅ V. User-Centric Design
- **Compliance**: Implementation ordered by user story priority (P1 → P2 → P3 → P4)
- **Independent deliverables**: Each priority level delivers standalone value
  - P1: Single-player basic scoring (immediate utility)
  - P2: Finish detection (strategic enhancement)
  - P3: Multiple game types (versatility)
  - P4: Multi-player (social/competitive)
- **Validation**: Acceptance scenarios defined for each user story in spec.md

### Summary
✅ **GATE PASSED**: All constitutional principles are satisfied. No violations requiring justification.

## Project Structure

### Documentation (this feature)

```
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```
lib/
├── main.dart                      # App entry point
├── models/                        # Data models
│   ├── game.dart
│   ├── player.dart
│   ├── turn.dart
│   ├── dart.dart
│   ├── game_type.dart
│   └── checkout_suggestion.dart
├── services/                      # Business logic layer
│   ├── game_engine/
│   │   ├── game_engine.dart
│   │   ├── rules/
│   │   │   ├── game_rule.dart
│   │   │   ├── five_oh_one_rule.dart
│   │   │   ├── three_oh_one_rule.dart
│   │   │   ├── cricket_rule.dart
│   │   │   └── around_clock_rule.dart
│   │   └── validators/
│   │       ├── score_validator.dart
│   │       └── finish_validator.dart
│   ├── checkout_calculator/
│   │   ├── checkout_calculator.dart
│   │   ├── checkout_database.dart
│   │   └── checkout_finder.dart
│   ├── persistence/
│   │   ├── database_service.dart
│   │   ├── game_repository.dart
│   │   └── migrations/
│   └── statistics/
│       └── stats_calculator.dart
├── ui/                            # User interface layer
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── game_setup_screen.dart
│   │   ├── game_screen.dart
│   │   └── history_screen.dart
│   ├── widgets/
│   │   ├── dartboard/
│   │   │   ├── dartboard_widget.dart
│   │   │   ├── dartboard_painter.dart
│   │   │   └── dartboard_zone.dart
│   │   ├── score_display.dart
│   │   ├── player_card.dart
│   │   ├── checkout_panel.dart
│   │   └── turn_history.dart
│   └── theme/
│       └── app_theme.dart
├── providers/                     # State management
│   ├── game_provider.dart
│   └── settings_provider.dart
└── utils/
    ├── constants.dart
    └── helpers.dart

test/
├── contract/                      # Contract tests
│   ├── game_engine_test.dart
│   ├── checkout_calculator_test.dart
│   └── persistence_test.dart
├── integration/                   # Integration tests
│   ├── game_flow_test.dart
│   ├── multi_player_test.dart
│   └── checkout_detection_test.dart
├── unit/                          # Unit tests
│   ├── models/
│   ├── services/
│   └── widgets/
└── test_helpers/
    ├── mock_data.dart
    └── test_utils.dart

android/                           # Android platform config (generated)
ios/                              # iOS platform config (generated)
```

**Structure Decision**: Standard Flutter mobile project structure using `lib/` for source code and `test/` for tests. Organized by layer (models, services, ui, providers) rather than by feature to maintain clear separation of concerns. The `services/` layer contains all business logic modules with clear subdirectories for each major component (game_engine, checkout_calculator, persistence, statistics). This supports modular development while keeping related code together.

## Complexity Tracking

*Fill ONLY if Constitution Check has violations that must be justified*

No violations - N/A

