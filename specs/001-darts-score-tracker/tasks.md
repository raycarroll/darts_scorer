# Tasks: Darts Score Tracker Mobile App

**Feature**: 001-darts-score-tracker
**Branch**: `001-darts-score-tracker`
**Generated**: 2025-10-23
**TDD Approach**: Tests BEFORE implementation (Constitutional Requirement - Principle II)

## Summary

This task list follows a Test-Driven Development (TDD) approach organized by user story priority. Each phase includes contract tests, integration tests, unit tests, implementation, and UI development. Tasks are dependency-ordered and marked with parallelization opportunities.

**Constitutional Note**: Test-First Development is MANDATORY per Principle II of the project constitution. All implementation tasks MUST be preceded by their corresponding test tasks.

---

## Phase 1: Project Setup & Foundation

### T001: Initialize Flutter Project [Setup]
**Description**: Create new Flutter project with proper structure
**Dependencies**: None
**Estimated Effort**: 30 minutes
**Steps**:
- Run `flutter create darts_scorer`
- Verify Flutter SDK version 3.24+, Dart 3.5+
- Set up project directory structure (lib/, test/)
- Configure analysis_options.yaml with linting rules
- Verify initial app runs on emulator/simulator
**Deliverable**: Working Flutter app scaffold
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/`

### T002: Configure Dependencies [Setup]
**Description**: Add required packages to pubspec.yaml
**Dependencies**: T001
**Estimated Effort**: 15 minutes
**Steps**:
- Add production dependencies:
  - sqflite: ^2.3.0 (SQLite database)
  - provider: ^6.1.0 (state management)
  - flutter_svg: ^2.0.0 (SVG dartboard graphics)
  - shared_preferences: ^2.2.0 (app settings)
- Add dev dependencies:
  - mockito: ^5.4.0 (mocking for tests)
  - build_runner: ^2.4.0 (code generation)
- Run `flutter pub get`
**Deliverable**: pubspec.yaml with all dependencies
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/pubspec.yaml`

### T003: Create Data Model Classes [Setup]
**Description**: Implement core data model entities
**Dependencies**: T002
**Estimated Effort**: 1 hour
**Parallelizable**: [P] - Can be done in parallel with test infrastructure
**Steps**:
- Create `lib/models/game.dart` - Game entity
- Create `lib/models/player.dart` - Player entity
- Create `lib/models/turn.dart` - Turn entity
- Create `lib/models/dart.dart` - Dart entity
- Create `lib/models/game_type.dart` - GameType enum
- Create `lib/models/multiplier.dart` - Multiplier enum
- Create `lib/models/game_status.dart` - GameStatus enum
- Create `lib/models/checkout_suggestion.dart` - CheckoutSuggestion class
- Implement toMap() and fromMap() for all entities
**Deliverable**: Complete data model classes matching data-model.md spec
**Paths**:
- `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/models/game.dart`
- `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/models/player.dart`
- `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/models/turn.dart`
- `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/models/dart.dart`
- `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/models/game_type.dart`
- `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/models/multiplier.dart`
- `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/models/game_status.dart`
- `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/models/checkout_suggestion.dart`

### T004: Setup Test Infrastructure [Setup]
**Description**: Create test directory structure and helpers
**Dependencies**: T002
**Estimated Effort**: 30 minutes
**Parallelizable**: [P] - Can be done in parallel with T003
**Steps**:
- Create test directory structure:
  - `test/contract/`
  - `test/integration/`
  - `test/unit/models/`
  - `test/unit/services/`
  - `test/unit/widgets/`
  - `test/test_helpers/`
- Create `test/test_helpers/mock_data.dart` - Sample test data
- Create `test/test_helpers/test_utils.dart` - Test utilities
- Configure test coverage reporting
**Deliverable**: Complete test infrastructure
**Paths**:
- `/home/raycarroll/Documents/Code/darts/darts_scorer/test/contract/`
- `/home/raycarroll/Documents/Code/darts/darts_scorer/test/integration/`
- `/home/raycarroll/Documents/Code/darts/darts_scorer/test/unit/`
- `/home/raycarroll/Documents/Code/darts/darts_scorer/test/test_helpers/`

---

## Phase 2: Database & Persistence Layer

### T005: Write Persistence Contract Tests [TEST - Phase 2]
**Description**: Write contract tests for PersistenceService API
**Dependencies**: T003, T004
**Estimated Effort**: 1 hour
**TDD**: RED - Write tests first
**Steps**:
- Create `test/contract/persistence_test.dart`
- Test DatabaseService.initialize()
- Test GameRepository.createGame()
- Test GameRepository.getGame()
- Test GameRepository.updateGame()
- Test GameRepository.deleteGame()
- Test PlayerRepository CRUD operations
- Test TurnRepository CRUD operations
- Test transaction atomicity
- Test foreign key constraints
- Verify tests FAIL (no implementation yet)
**Deliverable**: Complete contract test suite for persistence API
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/test/contract/persistence_test.dart`

### T006: Implement Database Schema [Implementation]
**Description**: Create SQLite database schema and migration logic
**Dependencies**: T005
**Estimated Effort**: 1.5 hours
**TDD**: GREEN - Implement to pass tests
**Steps**:
- Create `lib/services/persistence/database_service.dart`
- Implement DatabaseService class
- Create tables: games, players, turns, darts
- Add indexes per data-model.md
- Implement foreign key constraints
- Create migration strategy (version 1)
- Enable PRAGMA foreign_keys
- Verify T005 tests PASS
**Deliverable**: Working database schema with migrations
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/services/persistence/database_service.dart`

### T007: Implement Game Repository [Implementation]
**Description**: Implement CRUD operations for Game entities
**Dependencies**: T006
**Estimated Effort**: 1.5 hours
**TDD**: GREEN - Implement to pass tests
**Steps**:
- Create `lib/services/persistence/game_repository.dart`
- Implement GameRepository interface
- Implement createGame() with transaction
- Implement getGame() with joins
- Implement updateGame()
- Implement deleteGame() with cascade
- Implement getGames() with filtering
- Implement getActiveGame()
- Implement deleteOldGames()
- Verify T005 tests PASS for GameRepository
**Deliverable**: Complete GameRepository implementation
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/services/persistence/game_repository.dart`

### T008: Implement Player & Turn Repositories [Implementation]
**Description**: Implement CRUD operations for Player and Turn entities
**Dependencies**: T007
**Estimated Effort**: 2 hours
**TDD**: GREEN - Implement to pass tests
**Parallelizable**: [P] - PlayerRepository and TurnRepository can be implemented in parallel
**Steps**:
- Create `lib/services/persistence/player_repository.dart`
- Implement PlayerRepository interface
- Create `lib/services/persistence/turn_repository.dart`
- Implement TurnRepository interface
- Implement all CRUD methods per contract
- Verify ALL T005 tests PASS
**Deliverable**: Complete repository implementations
**Paths**:
- `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/services/persistence/player_repository.dart`
- `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/services/persistence/turn_repository.dart`

### T009: Write Persistence Integration Tests [TEST - Phase 2]
**Description**: Write integration tests for full persistence workflow
**Dependencies**: T008
**Estimated Effort**: 1 hour
**TDD**: Verify integration scenarios
**Steps**:
- Create `test/integration/persistence_integration_test.dart`
- Test full game creation with players
- Test game completion workflow
- Test data persistence across app restart
- Test database migration (v1)
- Test foreign key cascades
- Test transaction rollback on error
- Verify all tests PASS
**Deliverable**: Complete persistence integration tests
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/test/integration/persistence_integration_test.dart`

---

## Phase 3: User Story 1 - Basic Score Recording (MVP)

### T010: Write Checkout Calculator Contract Tests [TEST - US1]
**Description**: Write contract tests for CheckoutCalculator API
**Dependencies**: T003, T004
**Estimated Effort**: 1 hour
**TDD**: RED - Write tests first
**Parallelizable**: [P] - Can be done in parallel with persistence work
**Steps**:
- Create `test/contract/checkout_calculator_test.dart`
- Test findCheckouts() for various scores (2-170)
- Test isFinishable() for valid/invalid scores
- Test getBestCheckout() returns easiest option
- Test getMaxCheckout() for 1, 2, 3 darts
- Test impossible finishes return empty list
- Test checkout ordering by difficulty
- Verify tests FAIL (no implementation yet)
**Deliverable**: Complete contract test suite for CheckoutCalculator
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/test/contract/checkout_calculator_test.dart`

### T011: Implement Checkout Database [Implementation - US1]
**Description**: Create pre-computed checkout database
**Dependencies**: T010
**Estimated Effort**: 2 hours
**TDD**: GREEN - Implement to pass tests
**Steps**:
- Create `lib/services/checkout_calculator/checkout_database.dart`
- Create in-memory map with checkouts for scores 2-170
- Implement CheckoutSuggestion for each valid score
- Define impossible finishes list
- Calculate difficulty ratings
- Verify T010 tests for database lookups PASS
**Deliverable**: Complete checkout database with all finishable scores
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/services/checkout_calculator/checkout_database.dart`

### T012: Implement Checkout Calculator [Implementation - US1]
**Description**: Implement checkout calculation logic
**Dependencies**: T011
**Estimated Effort**: 1.5 hours
**TDD**: GREEN - Implement to pass tests
**Steps**:
- Create `lib/services/checkout_calculator/checkout_calculator.dart`
- Implement CheckoutCalculator interface
- Implement findCheckouts() with database lookup
- Implement algorithmic computation for missing scores
- Implement isFinishable() logic
- Implement getBestCheckout()
- Implement getMaxCheckout()
- Verify ALL T010 tests PASS
**Deliverable**: Complete CheckoutCalculator implementation
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/services/checkout_calculator/checkout_calculator.dart`

### T013: Write Game Engine Contract Tests [TEST - US1]
**Description**: Write contract tests for GameEngine API
**Dependencies**: T003, T004
**Estimated Effort**: 2 hours
**TDD**: RED - Write tests first
**Steps**:
- Create `test/contract/game_engine_test.dart`
- Test createGame() with 1-4 players
- Test recordDart() updates score correctly
- Test undoLastDart() functionality
- Test completeTurn() advances player
- Test validateDart() logic
- Test checkFinishAvailable()
- Test getGameState()
- Test abandonGame()
- Test error conditions (invalid inputs, state errors)
- Verify tests FAIL (no implementation yet)
**Deliverable**: Complete contract test suite for GameEngine
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/test/contract/game_engine_test.dart`

### T014: Implement 501 Game Rule [Implementation - US1]
**Description**: Implement FiveOhOneRule for 501 game type
**Dependencies**: T013
**Estimated Effort**: 1.5 hours
**TDD**: GREEN - Implement to pass tests
**Steps**:
- Create `lib/services/game_engine/rules/game_rule.dart` - Abstract interface
- Create `lib/services/game_engine/rules/five_oh_one_rule.dart`
- Implement calculateScore() with bust detection
- Implement isWinningDart() with double-out rule
- Implement isBust() logic (< 0, == 1, finish on non-double)
- Implement canFinishFrom() (max 170)
- Write unit tests for FiveOhOneRule
- Verify tests PASS
**Deliverable**: Complete FiveOhOneRule implementation
**Paths**:
- `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/services/game_engine/rules/game_rule.dart`
- `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/services/game_engine/rules/five_oh_one_rule.dart`
- `/home/raycarroll/Documents/Code/darts/darts_scorer/test/unit/services/game_engine/five_oh_one_rule_test.dart`

### T015: Implement Game Engine Core [Implementation - US1]
**Description**: Implement GameEngine with 501 game support
**Dependencies**: T014, T008, T012
**Estimated Effort**: 3 hours
**TDD**: GREEN - Implement to pass tests
**Steps**:
- Create `lib/services/game_engine/game_engine.dart`
- Implement GameEngine interface
- Inject PersistenceService, CheckoutCalculator dependencies
- Implement createGame()
- Implement recordDart() with rule validation
- Implement undoLastDart()
- Implement completeTurn() with turn rotation
- Implement validateDart()
- Implement checkFinishAvailable()
- Implement getGameState()
- Implement abandonGame()
- Verify ALL T013 tests PASS
**Deliverable**: Complete GameEngine implementation for 501
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/services/game_engine/game_engine.dart`

### T016: Write Dartboard Widget Tests [TEST - US1]
**Description**: Write widget tests for visual dartboard
**Dependencies**: T004
**Estimated Effort**: 1 hour
**TDD**: RED - Write tests first
**Parallelizable**: [P] - Can be done in parallel with T013-T015
**Steps**:
- Create `test/unit/widgets/dartboard_widget_test.dart`
- Test dartboard renders all zones (singles, doubles, triples, bulls)
- Test tap detection on different zones
- Test zone highlighting
- Test miss zone
- Test responsiveness to different screen sizes
- Verify tests FAIL (no implementation yet)
**Deliverable**: Complete widget test suite for dartboard
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/test/unit/widgets/dartboard_widget_test.dart`

### T017: Implement Dartboard Painter [Implementation - US1]
**Description**: Create custom painter for dartboard rendering
**Dependencies**: T016
**Estimated Effort**: 3 hours
**TDD**: GREEN - Implement to pass tests
**Steps**:
- Create `lib/ui/widgets/dartboard/dartboard_painter.dart`
- Implement CustomPainter for dartboard
- Draw dartboard zones: singles (1-20), doubles, triples, bulls
- Use dartboard number sequence: 20,1,18,4,13,6,10,15,2,17,3,19,7,16,8,11,14,9,12,5
- Draw segment boundaries and colors (black/white/red/green)
- Calculate zone boundaries for hit detection
- Verify T016 tests PASS
**Deliverable**: Complete dartboard painter
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/widgets/dartboard/dartboard_painter.dart`

### T018: Implement Dartboard Widget [Implementation - US1]
**Description**: Create interactive dartboard widget with gesture detection
**Dependencies**: T017
**Estimated Effort**: 2 hours
**TDD**: GREEN - Implement to pass tests
**Steps**:
- Create `lib/ui/widgets/dartboard/dartboard_widget.dart`
- Implement CustomPaint widget with DartboardPainter
- Add GestureDetector for tap handling
- Implement zone detection from tap coordinates
- Calculate zone (1-20, 25) and multiplier from tap position
- Emit onDartThrown callback with zone and multiplier
- Add visual feedback on tap (ripple effect)
- Verify ALL T016 tests PASS
**Deliverable**: Complete interactive dartboard widget
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/widgets/dartboard/dartboard_widget.dart`

### T019: Implement Score Display Widget [Implementation - US1]
**Description**: Create widget to display current score and game info
**Dependencies**: T003
**Estimated Effort**: 1 hour
**Steps**:
- Create `lib/ui/widgets/score_display.dart`
- Display current remaining score (large, prominent)
- Display starting score
- Display darts thrown in current turn (0-3)
- Display current round number
- Write widget tests
- Verify tests PASS
**Deliverable**: Score display widget
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/widgets/score_display.dart`

### T020: Implement Turn History Widget [Implementation - US1]
**Description**: Create widget to display turn history
**Dependencies**: T003
**Estimated Effort**: 1 hour
**Parallelizable**: [P] - Can be done in parallel with T019
**Steps**:
- Create `lib/ui/widgets/turn_history.dart`
- Display list of previous turns with scores
- Show individual dart scores within each turn
- Show turn totals and running score
- Add undo button for last dart
- Write widget tests
- Verify tests PASS
**Deliverable**: Turn history widget
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/widgets/turn_history.dart`

### T021: Create Game Provider [Implementation - US1]
**Description**: Implement state management for game
**Dependencies**: T015
**Estimated Effort**: 1.5 hours
**Steps**:
- Create `lib/providers/game_provider.dart`
- Extend ChangeNotifier for Provider pattern
- Inject GameEngine dependency
- Implement startNewGame()
- Implement recordDart() with notifyListeners()
- Implement undoLastDart()
- Implement completeTurn()
- Maintain GameState in memory
- Write unit tests for provider
- Verify tests PASS
**Deliverable**: Complete GameProvider for state management
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/providers/game_provider.dart`

### T022: Implement Game Setup Screen [Implementation - US1]
**Description**: Create screen for game setup
**Dependencies**: T021
**Estimated Effort**: 1.5 hours
**Steps**:
- Create `lib/ui/screens/game_setup_screen.dart`
- Add game type selector (501, 301, Cricket, Around the Clock) - default to 501
- Add player name input (single player for MVP)
- Add "Start Game" button
- Navigate to GameScreen on start
- Write widget tests
- Verify tests PASS
**Deliverable**: Game setup screen
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/screens/game_setup_screen.dart`

### T023: Implement Game Screen [Implementation - US1]
**Description**: Create main game screen with dartboard and score display
**Dependencies**: T018, T019, T020, T021
**Estimated Effort**: 2 hours
**Steps**:
- Create `lib/ui/screens/game_screen.dart`
- Use Consumer<GameProvider> for state
- Display DartboardWidget
- Display ScoreDisplay widget
- Display TurnHistory widget
- Wire up dartboard taps to GameProvider.recordDart()
- Add undo button
- Add complete turn button
- Show win dialog on game completion
- Write widget tests
- Verify tests PASS
**Deliverable**: Complete game screen for MVP
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/screens/game_screen.dart`

### T024: Implement Home Screen [Implementation - US1]
**Description**: Create home/landing screen
**Dependencies**: T022
**Estimated Effort**: 1 hour
**Steps**:
- Create `lib/ui/screens/home_screen.dart`
- Display app title and logo
- Add "New Game" button → navigate to GameSetupScreen
- Add "Resume Game" button (if active game exists)
- Add "History" button → navigate to HistoryScreen (placeholder)
- Write widget tests
- Verify tests PASS
**Deliverable**: Home screen
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/screens/home_screen.dart`

### T025: Update Main App Entry Point [Implementation - US1]
**Description**: Configure app with providers and routing
**Dependencies**: T024, T021
**Estimated Effort**: 30 minutes
**Steps**:
- Update `lib/main.dart`
- Wrap app with MultiProvider
- Provide GameProvider
- Set up MaterialApp with routes
- Configure theme
- Set HomeScreen as initial route
- Verify app runs end-to-end
**Deliverable**: Complete app entry point
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/main.dart`

### T026: Write US1 Integration Tests [TEST - US1]
**Description**: Write end-to-end tests for User Story 1 acceptance scenarios
**Dependencies**: T025
**Estimated Effort**: 2 hours
**TDD**: Verify all US1 acceptance criteria
**Steps**:
- Create `test/integration/us1_basic_scoring_test.dart`
- Test US1 Scenario 1: Tap T20, score decreases by 60 (501 → 441)
- Test US1 Scenario 2: Record 3-dart turn, score decreases correctly
- Test US1 Scenario 3: View current score, darts thrown, turn history
- Test US1 Scenario 4: Undo last dart, score reverts
- Test US1 Scenario 5: Tap miss zone, records 0 points
- Verify ALL scenarios PASS
**Deliverable**: Complete US1 integration tests
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/test/integration/us1_basic_scoring_test.dart`

---

## Phase 4: User Story 2 - Finish Detection & Checkout Suggestions

### T027: Write Finish Detection Tests [TEST - US2]
**Description**: Write tests for finish detection logic
**Dependencies**: T015
**Estimated Effort**: 1 hour
**TDD**: RED - Write tests first
**Steps**:
- Create `test/unit/services/finish_detection_test.dart`
- Test checkFinishAvailable() for score 170 (finishable)
- Test checkFinishAvailable() for score 50 (finishable)
- Test checkFinishAvailable() for score 1 (impossible)
- Test checkFinishAvailable() for score 169 (impossible)
- Test finish detection updates in real-time
- Verify tests FAIL (feature not implemented)
**Deliverable**: Finish detection test suite
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/test/unit/services/finish_detection_test.dart`

### T028: Enhance Game Engine with Finish Detection [Implementation - US2]
**Description**: Add finish detection to GameEngine
**Dependencies**: T027, T012
**Estimated Effort**: 1 hour
**TDD**: GREEN - Implement to pass tests
**Steps**:
- Update `lib/services/game_engine/game_engine.dart`
- Enhance getGameState() to check finish availability
- Call CheckoutCalculator.isFinishable()
- Set isFinishable flag in GameState
- Call CheckoutCalculator.findCheckouts() for suggestions
- Verify T027 tests PASS
**Deliverable**: Enhanced GameEngine with finish detection
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/services/game_engine/game_engine.dart`

### T029: Implement Checkout Panel Widget [Implementation - US2]
**Description**: Create widget to display checkout suggestions
**Dependencies**: T028
**Estimated Effort**: 1.5 hours
**Steps**:
- Create `lib/ui/widgets/checkout_panel.dart`
- Display "FINISH AVAILABLE" indicator when isFinishable
- Show list of checkout suggestions
- Display dart combinations (e.g., "T20-T20-Bull")
- Show difficulty rating (easy, moderate, hard, etc.)
- Highlight best (easiest) checkout
- Add visual styling (colors, icons)
- Write widget tests
- Verify tests PASS
**Deliverable**: Checkout panel widget
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/widgets/checkout_panel.dart`

### T030: Integrate Checkout Panel into Game Screen [Implementation - US2]
**Description**: Add checkout panel to game screen
**Dependencies**: T029, T023
**Estimated Effort**: 30 minutes
**Steps**:
- Update `lib/ui/screens/game_screen.dart`
- Add CheckoutPanel widget
- Show panel when GameState.isFinishable is true
- Update layout to accommodate panel
- Verify checkout suggestions appear correctly
**Deliverable**: Game screen with checkout panel
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/screens/game_screen.dart`

### T031: Write Bust Handling Tests [TEST - US2]
**Description**: Write tests for bust scenarios
**Dependencies**: T015
**Estimated Effort**: 1 hour
**TDD**: RED - Write tests first
**Steps**:
- Create `test/unit/services/bust_handling_test.dart`
- Test score goes below 0 → bust, score reverts
- Test score equals 1 → bust, score reverts
- Test finish on single/triple (not double) → bust
- Test finish on double with exact 0 → win
- Test bull (inner bull is double) finish → win
- Verify tests FAIL (if not already passing from T015)
**Deliverable**: Bust handling test suite
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/test/unit/services/bust_handling_test.dart`

### T032: Implement Bust Indicators in UI [Implementation - US2]
**Description**: Add visual bust indicators
**Dependencies**: T031, T030
**Estimated Effort**: 1 hour
**TDD**: GREEN - Implement to pass tests
**Steps**:
- Update `lib/ui/screens/game_screen.dart`
- Show "BUST" message when turn is bust
- Highlight busted dart in turn history (red background)
- Disable "Complete Turn" button when bust
- Require undo before continuing
- Show score of 1 as "BUST" state
- Verify T031 tests PASS
**Deliverable**: UI with bust indicators
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/screens/game_screen.dart`

### T033: Implement Win Celebration [Implementation - US2]
**Description**: Add win detection and celebration UI
**Dependencies**: T032
**Estimated Effort**: 1 hour
**Steps**:
- Update `lib/ui/screens/game_screen.dart`
- Detect game completion (GameStatus.completed)
- Show win dialog with confetti/celebration animation
- Display final statistics (total darts, average, etc.)
- Offer "New Game" and "View Stats" options
- Write widget tests for win dialog
- Verify tests PASS
**Deliverable**: Win celebration UI
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/screens/game_screen.dart`

### T034: Write US2 Integration Tests [TEST - US2]
**Description**: Write end-to-end tests for User Story 2 acceptance scenarios
**Dependencies**: T033
**Estimated Effort**: 1.5 hours
**TDD**: Verify all US2 acceptance criteria
**Steps**:
- Create `test/integration/us2_finish_detection_test.dart`
- Test US2 Scenario 1: Score 170 shows finish available with checkouts
- Test US2 Scenario 2: Score 50 shows multiple checkout options
- Test US2 Scenario 3: Score 1 shows bust indicator
- Test US2 Scenario 4: Score 60, hit T20 → finish on non-double → bust
- Test US2 Scenario 5: Score 40, hit D20 → win celebration
- Verify ALL scenarios PASS
**Deliverable**: Complete US2 integration tests
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/test/integration/us2_finish_detection_test.dart`

---

## Phase 5: User Story 3 - Multi-Game Type Support

### T035: Write 301 Game Rule Tests [TEST - US3]
**Description**: Write tests for ThreeOhOneRule
**Dependencies**: T014
**Estimated Effort**: 30 minutes
**TDD**: RED - Write tests first
**Steps**:
- Create `test/unit/services/game_engine/three_oh_one_rule_test.dart`
- Test starting score is 301
- Test same bust rules as 501
- Test same finish rules (double-out)
- Verify tests FAIL (no implementation yet)
**Deliverable**: ThreeOhOneRule test suite
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/test/unit/services/game_engine/three_oh_one_rule_test.dart`

### T036: Implement 301 Game Rule [Implementation - US3]
**Description**: Implement ThreeOhOneRule
**Dependencies**: T035
**Estimated Effort**: 30 minutes
**TDD**: GREEN - Implement to pass tests
**Steps**:
- Create `lib/services/game_engine/rules/three_oh_one_rule.dart`
- Extend or copy FiveOhOneRule logic
- Override startingScore to return 301
- Verify T035 tests PASS
**Deliverable**: ThreeOhOneRule implementation
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/services/game_engine/rules/three_oh_one_rule.dart`

### T037: Write Cricket Game Rule Tests [TEST - US3]
**Description**: Write tests for CricketRule
**Dependencies**: T014
**Estimated Effort**: 1 hour
**TDD**: RED - Write tests first
**Steps**:
- Create `test/unit/services/game_engine/cricket_rule_test.dart`
- Test mark-based scoring on 15-20 and bulls
- Test closing numbers (3 marks)
- Test scoring on open numbers after closing
- Test win condition (all numbers closed + highest score)
- Verify tests FAIL (no implementation yet)
**Deliverable**: CricketRule test suite
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/test/unit/services/game_engine/cricket_rule_test.dart`

### T038: Implement Cricket Game Rule [Implementation - US3]
**Description**: Implement CricketRule with mark-based scoring
**Dependencies**: T037
**Estimated Effort**: 2 hours
**TDD**: GREEN - Implement to pass tests
**Steps**:
- Create `lib/services/game_engine/rules/cricket_rule.dart`
- Implement GameRule interface
- Implement mark accumulation (singles=1, doubles=2, triples=3)
- Track closed numbers per player
- Implement scoring on opponent's open numbers
- Implement win detection (all closed + highest score)
- No bust condition for Cricket
- Verify T037 tests PASS
**Deliverable**: CricketRule implementation
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/services/game_engine/rules/cricket_rule.dart`

### T039: Write Around the Clock Rule Tests [TEST - US3]
**Description**: Write tests for AroundClockRule
**Dependencies**: T014
**Estimated Effort**: 45 minutes
**TDD**: RED - Write tests first
**Steps**:
- Create `test/unit/services/game_engine/around_clock_rule_test.dart`
- Test sequential hitting: 1, 2, 3, ..., 20, then bullseye
- Test any multiplier counts (single, double, triple)
- Test wrong number doesn't advance
- Test win on bullseye after 20
- Verify tests FAIL (no implementation yet)
**Deliverable**: AroundClockRule test suite
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/test/unit/services/game_engine/around_clock_rule_test.dart`

### T040: Implement Around the Clock Rule [Implementation - US3]
**Description**: Implement AroundClockRule
**Dependencies**: T039
**Estimated Effort**: 1.5 hours
**TDD**: GREEN - Implement to pass tests
**Steps**:
- Create `lib/services/game_engine/rules/around_clock_rule.dart`
- Implement GameRule interface
- Track current target number (1-20, then 25)
- Implement hit detection (any multiplier)
- Advance target on hit
- Implement win detection (hit bullseye after 20)
- No bust condition
- Verify T039 tests PASS
**Deliverable**: AroundClockRule implementation
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/services/game_engine/rules/around_clock_rule.dart`

### T041: Update Game Engine for Multi-Game Support [Implementation - US3]
**Description**: Enhance GameEngine to support all game types
**Dependencies**: T036, T038, T040
**Estimated Effort**: 1 hour
**Steps**:
- Update `lib/services/game_engine/game_engine.dart`
- Add rule factory: select rule based on GameType
- Update createGame() to use correct rule
- Update recordDart() to use game-specific rule
- Update checkFinishAvailable() for non-501/301 games (no checkouts for Cricket/Around the Clock)
- Write integration tests for each game type
- Verify tests PASS
**Deliverable**: GameEngine supporting all 4 game types
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/services/game_engine/game_engine.dart`

### T042: Update Game Setup Screen for Game Type Selection [Implementation - US3]
**Description**: Add game type selector to setup screen
**Dependencies**: T041, T022
**Estimated Effort**: 30 minutes
**Steps**:
- Update `lib/ui/screens/game_setup_screen.dart`
- Add dropdown/radio buttons for game type (501, 301, Cricket, Around the Clock)
- Update UI labels based on selected type
- Pass selected type to GameProvider.startNewGame()
- Verify game type selection works
**Deliverable**: Enhanced game setup screen
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/screens/game_setup_screen.dart`

### T043: Create Cricket Score Display Widget [Implementation - US3]
**Description**: Create specialized score display for Cricket
**Dependencies**: T038, T019
**Estimated Effort**: 1.5 hours
**Steps**:
- Create `lib/ui/widgets/cricket_score_display.dart`
- Display marks for numbers 15-20 and bulls
- Show visual marks (/, X, ⊗ for 1, 2, 3 marks)
- Highlight closed numbers
- Display current points
- Write widget tests
- Verify tests PASS
**Deliverable**: Cricket score display widget
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/widgets/cricket_score_display.dart`

### T044: Update Game Screen for Multi-Game Display [Implementation - US3]
**Description**: Conditionally render game-specific UI
**Dependencies**: T043, T041
**Estimated Effort**: 1 hour
**Steps**:
- Update `lib/ui/screens/game_screen.dart`
- Show ScoreDisplay for 501/301 games
- Show CricketScoreDisplay for Cricket games
- Show sequential target for Around the Clock
- Conditionally show CheckoutPanel (only for 501/301)
- Highlight relevant dartboard zones (e.g., current target in Around the Clock)
- Verify UI adapts to game type
**Deliverable**: Game screen with multi-game support
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/screens/game_screen.dart`

### T045: Write US3 Integration Tests [TEST - US3]
**Description**: Write end-to-end tests for User Story 3 acceptance scenarios
**Dependencies**: T044
**Estimated Effort**: 2 hours
**TDD**: Verify all US3 acceptance criteria
**Steps**:
- Create `test/integration/us3_multi_game_test.dart`
- Test US3 Scenario 1: Select 301, game starts with 301
- Test US3 Scenario 2: Select Cricket, mark-based scoring works
- Test US3 Scenario 3: Cricket scoring on open numbers
- Test US3 Scenario 4: Around the Clock sequential hitting
- Test US3 Scenario 5: Dartboard highlights relevant zones per game type
- Verify ALL scenarios PASS
**Deliverable**: Complete US3 integration tests
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/test/integration/us3_multi_game_test.dart`

---

## Phase 6: User Story 4 - Multi-Player Score Tracking

### T046: Write Multi-Player Game Tests [TEST - US4]
**Description**: Write tests for multi-player functionality
**Dependencies**: T015
**Estimated Effort**: 1 hour
**TDD**: RED - Write tests first
**Steps**:
- Create `test/unit/services/multi_player_test.dart`
- Test createGame() with 2-4 players
- Test turn rotation (player 1 → 2 → 3 → 1)
- Test round increment when all players complete turn
- Test independent score tracking per player
- Test win detection in multi-player
- Verify tests FAIL (feature not fully implemented)
**Deliverable**: Multi-player test suite
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/test/unit/services/multi_player_test.dart`

### T047: Enhance Game Engine for Multi-Player [Implementation - US4]
**Description**: Add multi-player turn rotation logic
**Dependencies**: T046, T041
**Estimated Effort**: 2 hours
**TDD**: GREEN - Implement to pass tests
**Steps**:
- Update `lib/services/game_engine/game_engine.dart`
- Implement turn rotation: advance to next player on completeTurn()
- Track current player by orderPosition
- Increment round when all players complete turn
- Handle player finishing early (mark inactive, continue round)
- Update getGameState() to include all players
- Verify T046 tests PASS
**Deliverable**: GameEngine with multi-player support
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/services/game_engine/game_engine.dart`

### T048: Update Game Setup for Multi-Player [Implementation - US4]
**Description**: Add player management to game setup
**Dependencies**: T047, T042
**Estimated Effort**: 1.5 hours
**Steps**:
- Update `lib/ui/screens/game_setup_screen.dart`
- Add player count selector (1-4 players)
- Add text fields for player names (dynamic based on count)
- Validate unique player names
- Pass player names to GameProvider.startNewGame()
- Write widget tests
- Verify tests PASS
**Deliverable**: Game setup with multi-player configuration
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/screens/game_setup_screen.dart`

### T049: Implement Player Card Widget [Implementation - US4]
**Description**: Create widget to display individual player info
**Dependencies**: T047
**Estimated Effort**: 1 hour
**Steps**:
- Create `lib/ui/widgets/player_card.dart`
- Display player name
- Display current score
- Display statistics (average per dart, per turn)
- Highlight current player (border, background color)
- Show inactive status if player finished
- Write widget tests
- Verify tests PASS
**Deliverable**: Player card widget
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/widgets/player_card.dart`

### T050: Update Game Screen for Multi-Player Display [Implementation - US4]
**Description**: Show all players in game screen
**Dependencies**: T049, T044
**Estimated Effort**: 1.5 hours
**Steps**:
- Update `lib/ui/screens/game_screen.dart`
- Display PlayerCard for each player
- Arrange in grid or list layout
- Highlight current player's card
- Show current player's turn history
- Update score display to show active player
- Verify multi-player UI works
**Deliverable**: Game screen with multi-player UI
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/screens/game_screen.dart`

### T051: Implement Player Statistics Calculator [Implementation - US4]
**Description**: Calculate and display player statistics
**Dependencies**: T047
**Estimated Effort**: 1.5 hours
**Steps**:
- Create `lib/services/statistics/stats_calculator.dart`
- Implement calculatePlayerStats()
- Calculate total darts thrown
- Calculate average per dart
- Calculate average per turn (3 darts)
- Calculate highest turn score
- Calculate checkout percentage
- Write unit tests
- Verify tests PASS
**Deliverable**: Statistics calculator service
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/services/statistics/stats_calculator.dart`

### T052: Integrate Statistics into UI [Implementation - US4]
**Description**: Display player statistics in game and win screens
**Dependencies**: T051, T050
**Estimated Effort**: 1 hour
**Steps**:
- Update `lib/ui/widgets/player_card.dart` to show stats
- Update win dialog to show final stats for all players
- Add statistics view/modal for detailed stats
- Write widget tests
- Verify stats display correctly
**Deliverable**: UI with player statistics
**Paths**:
- `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/widgets/player_card.dart`
- `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/screens/game_screen.dart`

### T053: Write US4 Integration Tests [TEST - US4]
**Description**: Write end-to-end tests for User Story 4 acceptance scenarios
**Dependencies**: T052
**Estimated Effort**: 2 hours
**TDD**: Verify all US4 acceptance criteria
**Steps**:
- Create `test/integration/us4_multi_player_test.dart`
- Test US4 Scenario 1: Create game with 3 players, all initialize correctly
- Test US4 Scenario 2: Alice completes turn, advances to Bob
- Test US4 Scenario 3: View all players' scores and stats
- Test US4 Scenario 4: Bob finishes, displayed as winner
- Test US4 Scenario 5: Undo only affects current player
- Verify ALL scenarios PASS
**Deliverable**: Complete US4 integration tests
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/test/integration/us4_multi_player_test.dart`

---

## Phase 7: Polish, Error Handling & Accessibility

### T054: Implement App Theme [Polish]
**Description**: Create consistent app theme and styling
**Dependencies**: T025
**Estimated Effort**: 1 hour
**Steps**:
- Create `lib/ui/theme/app_theme.dart`
- Define color palette (primary, secondary, background, error)
- Define text styles (headers, body, labels)
- Define button styles
- Define dartboard colors (traditional: black, white, red, green)
- Apply theme to MaterialApp
- Verify consistent styling across app
**Deliverable**: Complete app theme
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/theme/app_theme.dart`

### T055: Add Loading States [Polish]
**Description**: Add loading indicators for async operations
**Dependencies**: T050
**Estimated Effort**: 1 hour
**Steps**:
- Update `lib/providers/game_provider.dart` to track loading state
- Show CircularProgressIndicator during game creation
- Show loading during database operations
- Add skeleton screens for initial load
- Write tests for loading states
- Verify loading indicators appear correctly
**Deliverable**: UI with loading states
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/providers/game_provider.dart`

### T056: Implement Error Handling UI [Polish]
**Description**: Add error handling and user feedback
**Dependencies**: T055
**Estimated Effort**: 1.5 hours
**Steps**:
- Update `lib/providers/game_provider.dart` to track error state
- Show SnackBar for errors (database errors, validation errors)
- Add error dialogs for critical errors
- Implement retry logic for transient errors
- Add error boundary widget
- Write tests for error scenarios
- Verify error handling works
**Deliverable**: UI with error handling
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/providers/game_provider.dart`

### T057: Add Animations [Polish]
**Description**: Add smooth animations for better UX
**Dependencies**: T054
**Estimated Effort**: 2 hours
**Steps**:
- Add score change animation (fade in/out)
- Add turn completion animation (slide transition)
- Add dartboard tap animation (ripple + scale)
- Add win celebration animation (confetti, bounce)
- Add page transitions
- Keep animations under 300ms for responsiveness
- Write tests for animations
- Verify animations are smooth
**Deliverable**: App with smooth animations
**Paths**: Various UI files

### T058: Implement Haptic Feedback [Polish]
**Description**: Add haptic feedback for user interactions
**Dependencies**: T057
**Estimated Effort**: 30 minutes
**Steps**:
- Add haptic feedback on dartboard tap
- Add haptic feedback on button press
- Add haptic feedback on undo
- Add haptic feedback on win
- Use HapticFeedback.lightImpact() from Flutter
- Make haptic feedback optional in settings
- Verify haptic works on device
**Deliverable**: Haptic feedback integration
**Paths**: Various UI files

### T059: Add Accessibility Features [Polish]
**Description**: Improve accessibility (a11y) support
**Dependencies**: T054
**Estimated Effort**: 2 hours
**Steps**:
- Add Semantics widgets to dartboard zones
- Add Semantics to all interactive elements
- Ensure color contrast meets WCAG AA standards
- Add screen reader support for score announcements
- Test with TalkBack (Android) and VoiceOver (iOS)
- Add large touch targets (min 48x48dp)
- Write accessibility tests
- Verify accessibility features work
**Deliverable**: App with accessibility support
**Paths**: Various UI files

### T060: Implement Game History Screen [Polish]
**Description**: Create screen to view past games
**Dependencies**: T008, T024
**Estimated Effort**: 2 hours
**Steps**:
- Create `lib/ui/screens/history_screen.dart`
- Query GameRepository.getGames() for completed games
- Display list of games with date, players, winner
- Add tap to view game details
- Add filter by game type
- Add delete game option
- Write widget tests
- Verify history screen works
**Deliverable**: Game history screen
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/screens/history_screen.dart`

### T061: Implement Settings Screen [Polish]
**Description**: Create settings screen for app preferences
**Dependencies**: T002
**Estimated Effort**: 1.5 hours
**Steps**:
- Create `lib/ui/screens/settings_screen.dart`
- Create `lib/providers/settings_provider.dart`
- Add settings: haptic feedback on/off, sound on/off, theme (light/dark)
- Use SharedPreferences for persistence
- Add about/version info
- Write widget tests
- Verify settings persist across app restart
**Deliverable**: Settings screen
**Paths**:
- `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/screens/settings_screen.dart`
- `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/providers/settings_provider.dart`

### T062: Add Sound Effects [Polish]
**Description**: Add sound effects for game events
**Dependencies**: T061
**Estimated Effort**: 1 hour
**Steps**:
- Add sound package (audioplayers or soundpool)
- Add sounds for: dartboard hit, turn complete, bust, win
- Integrate with settings (sound on/off)
- Keep sound files small (<50KB each)
- Write tests for sound playback
- Verify sounds play correctly
**Deliverable**: Sound effects integration
**Paths**: Various UI files + assets/sounds/

### T063: Implement Resume Game Feature [Polish]
**Description**: Allow resuming active game from home screen
**Dependencies**: T024, T008
**Estimated Effort**: 1 hour
**Steps**:
- Update `lib/ui/screens/home_screen.dart`
- Query GameRepository.getActiveGame() on load
- Show "Resume Game" button if active game exists
- Navigate to GameScreen with existing game state
- Load game state into GameProvider
- Write tests for resume functionality
- Verify resume works correctly
**Deliverable**: Resume game feature
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/screens/home_screen.dart`

### T064: Add Confirmation Dialogs [Polish]
**Description**: Add confirmation for destructive actions
**Dependencies**: T056
**Estimated Effort**: 1 hour
**Steps**:
- Add confirmation dialog for abandon game
- Add confirmation dialog for delete game (in history)
- Add confirmation dialog for undo (optional)
- Use platform-specific dialogs (Cupertino/Material)
- Write tests for dialogs
- Verify dialogs prevent accidental actions
**Deliverable**: Confirmation dialogs
**Paths**: Various UI files

### T065: Optimize Dartboard Rendering Performance [Polish]
**Description**: Ensure dartboard renders at 60 fps
**Dependencies**: T017
**Estimated Effort**: 1.5 hours
**Steps**:
- Profile dartboard rendering with DevTools
- Optimize CustomPainter (cache Paint objects)
- Use RepaintBoundary for dartboard widget
- Minimize rebuilds (use const widgets where possible)
- Test on low-end devices
- Verify consistent 60 fps
**Deliverable**: Optimized dartboard performance
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/lib/ui/widgets/dartboard/dartboard_painter.dart`

### T066: Write Edge Case Tests [TEST - Polish]
**Description**: Test edge cases and error scenarios
**Dependencies**: T053
**Estimated Effort**: 2 hours
**TDD**: Verify robustness
**Steps**:
- Create `test/integration/edge_cases_test.dart`
- Test bust scenarios: score < 0, score = 1, finish on non-double
- Test 9-dart finish (perfect game)
- Test device rotation during game
- Test app backgrounding and resumption
- Test database corruption recovery
- Test invalid checkout scores
- Test Cricket both players close same number
- Verify all edge cases handled gracefully
**Deliverable**: Edge case test suite
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/test/integration/edge_cases_test.dart`

### T067: Add App Icon and Splash Screen [Polish]
**Description**: Create app icon and splash screen
**Dependencies**: T054
**Estimated Effort**: 1 hour
**Steps**:
- Design app icon (dartboard theme)
- Generate icon assets for iOS and Android (flutter_launcher_icons)
- Create splash screen with app logo
- Configure native splash screen (flutter_native_splash)
- Verify icon and splash appear correctly
**Deliverable**: App icon and splash screen
**Paths**:
- `assets/icons/`
- `android/app/src/main/res/`
- `ios/Runner/Assets.xcassets/`

### T068: Final Integration Testing [TEST - Polish]
**Description**: Comprehensive end-to-end testing
**Dependencies**: T067
**Estimated Effort**: 3 hours
**TDD**: Verify complete app functionality
**Steps**:
- Test complete 501 game (single player)
- Test complete Cricket game (multi-player)
- Test all user stories (US1-US4) end-to-end
- Test on multiple devices (Android, iOS)
- Test on different screen sizes (phone, tablet)
- Test performance (load times, frame rate)
- Test memory usage (no leaks)
- Verify all features work together
**Deliverable**: Complete integration test suite + manual test results
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/test/integration/final_integration_test.dart`

### T069: Documentation and README [Polish]
**Description**: Write user documentation
**Dependencies**: T068
**Estimated Effort**: 1 hour
**Steps**:
- Update README.md with app description
- Add screenshots of key features
- Add installation instructions
- Add usage guide (how to play each game type)
- Document known issues
- Add contribution guidelines
- Verify documentation is clear
**Deliverable**: Complete README.md
**Path**: `/home/raycarroll/Documents/Code/darts/darts_scorer/README.md`

### T070: Build Release APK/IPA [Polish]
**Description**: Create release builds for distribution
**Dependencies**: T069
**Estimated Effort**: 1 hour
**Steps**:
- Configure release signing (Android keystore, iOS provisioning)
- Build Android APK: `flutter build apk --release`
- Build Android App Bundle: `flutter build appbundle --release`
- Build iOS IPA: `flutter build ios --release`
- Test release builds on device
- Verify app size < 50MB
- Verify performance in release mode
**Deliverable**: Release APK and IPA files
**Paths**:
- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/bundle/release/app-release.aab`
- `build/ios/iphoneos/Runner.app`

---

## Task Summary

### Total Tasks: 70

### Tasks by Phase:
- **Phase 1 (Setup & Foundation)**: 4 tasks (T001-T004)
- **Phase 2 (Database & Persistence)**: 5 tasks (T005-T009)
- **Phase 3 (US1 - Basic Scoring MVP)**: 17 tasks (T010-T026)
- **Phase 4 (US2 - Finish Detection)**: 8 tasks (T027-T034)
- **Phase 5 (US3 - Multi-Game Types)**: 11 tasks (T035-T045)
- **Phase 6 (US4 - Multi-Player)**: 8 tasks (T046-T053)
- **Phase 7 (Polish & Finalization)**: 17 tasks (T054-T070)

### MVP Scope (Phase 3 - US1):
Tasks T001-T026 (26 tasks total including setup and foundational work)

**MVP Deliverables**:
- Single-player 501 game
- Interactive visual dartboard
- Score tracking and turn history
- Undo functionality
- Basic UI with home, setup, and game screens
- SQLite persistence
- Complete test coverage for MVP features

### Test Coverage:
- **Contract Tests**: 3 tasks (T005, T010, T013)
- **Integration Tests**: 7 tasks (T009, T026, T034, T045, T053, T066, T068)
- **Unit Tests**: Embedded in implementation tasks (all TDD tasks include unit tests)
- **Widget Tests**: Embedded in UI implementation tasks
- **Total Test Tasks**: 37 tasks (53% of all tasks follow TDD approach)

### Parallelization Opportunities:
Tasks marked with [P] can be executed in parallel:
- T003 and T004 (data models + test infrastructure)
- T010-T013 (checkout calculator work parallel to game engine setup)
- T016-T018 (dartboard widget work parallel to game engine)
- T019 and T020 (score display + turn history widgets)
- T008 (PlayerRepository and TurnRepository)

### Dependency Chain (Critical Path):
T001 → T002 → T003 → T005 → T006 → T007 → T008 → T013 → T014 → T015 → T021 → T022 → T023 → T025 → T026

**Critical Path Duration**: ~30 hours (estimated for MVP)

---

## Notes

1. **TDD Approach**: All implementation tasks (marked as "Implementation") are preceded by corresponding test tasks (marked as "TEST"). This satisfies the constitutional requirement for Test-First Development.

2. **User Story Organization**: Tasks are organized by user story priority (P1→P4) to ensure incremental delivery of value.

3. **Flutter Conventions**: All paths use Flutter conventions (lib/ for source, test/ for tests).

4. **Exact File Paths**: All file paths are absolute and follow the project structure defined in plan.md.

5. **Contract Compliance**: Tasks reference contracts from contracts/ directory (game_engine_api.md, checkout_calculator_api.md, persistence_api.md).

6. **Estimated Effort**: Total estimated effort is ~90-100 hours for complete implementation.

7. **Testing**: Every feature has corresponding tests written BEFORE implementation (TDD). Integration tests validate user story acceptance criteria.

8. **Incremental Delivery**: Each phase produces working, testable software that builds on previous phases.

---

**Next Steps**:
1. Execute Phase 1 tasks (T001-T004) to establish project foundation
2. Execute Phase 2 tasks (T005-T009) to build persistence layer
3. Execute Phase 3 tasks (T010-T026) to deliver MVP (US1)
4. Execute subsequent phases in order (US2→US3→US4→Polish)
5. Run `/speckit.implement` command to execute tasks automatically
