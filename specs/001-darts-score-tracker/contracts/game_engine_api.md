# Game Engine API Contract

**Module**: `lib/services/game_engine/`
**Version**: 1.0
**Date**: 2025-10-23

## Overview

The GameEngine is responsible for managing game state, enforcing game rules, validating moves, and determining win conditions. It is the central business logic component that coordinates all game operations.

## Public Interface

### GameEngine Class

```dart
abstract class GameEngine {
  /// Creates a new game with specified type and players
  ///
  /// Parameters:
  ///   - gameType: Type of darts game (501, 301, Cricket, Around the Clock)
  ///   - playerNames: List of 1-4 player names
  ///
  /// Returns: New Game instance with initialized players
  ///
  /// Throws:
  ///   - ArgumentError if playerNames is empty or > 4 players
  ///   - ArgumentError if player names are not unique
  Future<Game> createGame({
    required GameType gameType,
    required List<String> playerNames,
  });

  /// Records a dart throw for the current player
  ///
  /// Parameters:
  ///   - gameId: ID of the active game
  ///   - zone: Dartboard zone hit (0=miss, 1-20, 25=bull)
  ///   - multiplier: Single, double, triple, outerBull, or innerBull
  ///
  /// Returns: Updated GameState with new score and turn info
  ///
  /// Throws:
  ///   - StateError if game is not active
  ///   - ArgumentError if zone or multiplier is invalid
  ///   - StateError if turn already has 3 darts
  Future<GameState> recordDart({
    required String gameId,
    required int zone,
    required Multiplier multiplier,
  });

  /// Undoes the last dart thrown in the current turn
  ///
  /// Parameters:
  ///   - gameId: ID of the active game
  ///
  /// Returns: Updated GameState with dart removed
  ///
  /// Throws:
  ///   - StateError if game is not active
  ///   - StateError if current turn has no darts to undo
  Future<GameState> undoLastDart(String gameId);

  /// Completes the current turn and advances to next player
  ///
  /// Parameters:
  ///   - gameId: ID of the active game
  ///
  /// Returns: Updated GameState with next player active
  ///
  /// Throws:
  ///   - StateError if game is not active
  ///   - StateError if current turn is bust (must undo first)
  Future<GameState> completeTurn(String gameId);

  /// Validates whether a dart throw is legal in current game state
  ///
  /// Parameters:
  ///   - gameId: ID of the active game
  ///   - zone: Dartboard zone to validate
  ///   - multiplier: Multiplier to validate
  ///
  /// Returns: ValidationResult with isValid flag and error message
  Future<ValidationResult> validateDart({
    required String gameId,
    required int zone,
    required Multiplier multiplier,
  });

  /// Checks if current player can finish the game this turn
  ///
  /// Parameters:
  ///   - gameId: ID of the active game
  ///
  /// Returns: FinishStatus with canFinish flag and remaining checkouts
  Future<FinishStatus> checkFinishAvailable(String gameId);

  /// Gets current game state including scores, turn info, and statistics
  ///
  /// Parameters:
  ///   - gameId: ID of the game to query
  ///
  /// Returns: GameState with all current information
  ///
  /// Throws:
  ///   - ArgumentError if game not found
  Future<GameState> getGameState(String gameId);

  /// Abandons an active game (marks as abandoned, no winner)
  ///
  /// Parameters:
  ///   - gameId: ID of the game to abandon
  ///
  /// Returns: Final GameState with status=abandoned
  ///
  /// Throws:
  ///   - ArgumentError if game not found
  ///   - StateError if game is already completed
  Future<GameState> abandonGame(String gameId);
}
```

## Data Structures

### GameState

```dart
class GameState {
  final Game game;
  final List<Player> players;
  final Player currentPlayer;
  final Turn? currentTurn;
  final int currentRound;
  final bool isFinishable;
  final List<CheckoutSuggestion> checkouts;
  final Map<String, PlayerStats> playerStats;

  GameState({
    required this.game,
    required this.players,
    required this.currentPlayer,
    this.currentTurn,
    required this.currentRound,
    required this.isFinishable,
    this.checkouts = const [],
    required this.playerStats,
  });
}
```

### ValidationResult

```dart
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final ValidationError? errorType;

  ValidationResult.valid() : isValid = true, errorMessage = null, errorType = null;

  ValidationResult.invalid(this.errorMessage, this.errorType) : isValid = false;
}

enum ValidationError {
  invalidZone,        // Zone not 0, 1-20, or 25
  invalidMultiplier,  // Multiplier doesn't match zone
  gameNotActive,      // Game is completed or abandoned
  turnComplete,       // Turn already has 3 darts
  bustThrow,          // Throw would cause a bust
}
```

### FinishStatus

```dart
class FinishStatus {
  final bool canFinish;
  final int remainingScore;
  final List<CheckoutSuggestion> suggestions;

  FinishStatus({
    required this.canFinish,
    required this.remainingScore,
    this.suggestions = const [],
  });
}
```

## Game Rules Interface

Each game type implements the `GameRule` interface:

```dart
abstract class GameRule {
  /// Game type this rule applies to
  GameType get gameType;

  /// Starting score for this game type
  int get startingScore;

  /// Calculate score after a dart is thrown
  ///
  /// Parameters:
  ///   - currentScore: Player's current score
  ///   - dart: Dart that was thrown
  ///
  /// Returns: New score, or null if bust
  int? calculateScore(int currentScore, Dart dart);

  /// Check if the game is won after this dart
  ///
  /// Parameters:
  ///   - currentScore: Player's score after dart
  ///   - dart: Dart that was thrown
  ///
  /// Returns: true if game is won, false otherwise
  bool isWinningDart(int currentScore, Dart dart);

  /// Check if a dart causes a bust
  ///
  /// Parameters:
  ///   - currentScore: Player's score before dart
  ///   - dart: Dart to check
  ///
  /// Returns: true if dart causes bust, false otherwise
  bool isBust(int currentScore, Dart dart);

  /// Check if a finish is possible from this score
  ///
  /// Parameters:
  ///   - score: Current remaining score
  ///   - dartsRemaining: Number of darts left in turn (1-3)
  ///
  /// Returns: true if finish is mathematically possible
  bool canFinishFrom(int score, int dartsRemaining);

  /// Get valid checkout suggestions for a score
  ///
  /// Parameters:
  ///   - score: Score to finish from
  ///   - dartsRemaining: Number of darts available (1-3)
  ///
  /// Returns: List of valid checkout suggestions
  List<CheckoutSuggestion> getCheckoutSuggestions(int score, int dartsRemaining);
}
```

## Concrete Rule Implementations

### FiveOhOneRule / ThreeOhOneRule

```dart
class FiveOhOneRule implements GameRule {
  @override
  GameType get gameType => GameType.fiveOhOne;

  @override
  int get startingScore => 501;

  @override
  int? calculateScore(int currentScore, Dart dart) {
    int newScore = currentScore - dart.points;

    // Bust if score goes below 0 or equals 1
    if (newScore < 0 || newScore == 1) {
      return null;  // Bust
    }

    return newScore;
  }

  @override
  bool isWinningDart(int currentScore, Dart dart) {
    // Must finish on a double
    return currentScore == 0 &&
           (dart.multiplier == Multiplier.double ||
            dart.multiplier == Multiplier.innerBull);
  }

  @override
  bool isBust(int currentScore, Dart dart) {
    int newScore = currentScore - dart.points;

    // Bust conditions:
    // 1. Score goes below 0
    // 2. Score equals 1 (can't finish)
    // 3. Score reaches 0 but not on a double
    if (newScore < 0 || newScore == 1) {
      return true;
    }

    if (newScore == 0) {
      bool isDouble = dart.multiplier == Multiplier.double ||
                     dart.multiplier == Multiplier.innerBull;
      return !isDouble;  // Bust if not finished on double
    }

    return false;
  }

  @override
  bool canFinishFrom(int score, int dartsRemaining) {
    // Maximum possible: T20 + T20 + Bull = 60 + 60 + 50 = 170
    // Must be <= 170 and not in impossible list
    if (score > 170) return false;

    // Impossible finishes (odd numbers that can't be made with double finish)
    const impossibleScores = [169, 168, 166, 165, 163, 162, 159];
    if (impossibleScores.contains(score)) return false;

    return true;
  }

  @override
  List<CheckoutSuggestion> getCheckoutSuggestions(int score, int dartsRemaining) {
    // Delegate to CheckoutCalculator service
    // (GameEngine depends on CheckoutCalculator for this)
    throw UnimplementedError('Use CheckoutCalculator.findCheckouts()');
  }
}
```

## Behavior Contracts

### Turn Lifecycle

1. **Turn Start**: GameEngine creates new Turn when player's turn begins
2. **Dart Recording**: Up to 3 darts can be recorded via `recordDart()`
3. **Bust Handling**: If dart causes bust, turn score reverts, player cannot complete turn until undo
4. **Turn Completion**: `completeTurn()` advances to next player, starts new turn
5. **Win Detection**: If dart results in win, game status changes to completed, winner is set

### Turn Rotation

**Single Player**:
- Round increments after each turn
- Turn number increments sequentially

**Multi-Player** (2-4 players):
- Players take turns in order (orderPosition 0, 1, 2, 3)
- Round increments when all players complete their turn
- If player finishes, remaining players can complete the round (unless option to end immediately)

### Bust Rules by Game Type

**501 / 301**:
- Score goes below 0: **BUST** (revert to score before turn)
- Score equals 1: **BUST** (cannot finish from 1)
- Score reaches 0 on non-double: **BUST** (must finish on double)

**Cricket**:
- No bust condition (marks accumulate)

**Around the Clock**:
- No bust condition (must hit current target)

## Error Handling

### Exceptions Thrown

| Exception | Condition | Recovery |
|-----------|-----------|----------|
| `ArgumentError` | Invalid parameters (zone, multiplier, player count) | Fix parameters and retry |
| `StateError` | Invalid state transition (game not active, turn complete) | Check game state first |
| `StateError` | Attempting action on busted turn | Undo dart before completing turn |

### Error Messages

- `"Game {id} not found"` - Game ID doesn't exist
- `"Game is not active"` - Attempting to modify completed/abandoned game
- `"Turn already has 3 darts"` - Cannot record 4th dart
- `"Cannot undo - no darts in current turn"` - Nothing to undo
- `"Cannot complete turn - turn is bust"` - Must undo before completing
- `"Invalid zone: must be 0, 1-20, or 25"` - Zone out of range
- `"Invalid multiplier for zone"` - e.g., triple 25 doesn't exist

## Dependencies

### Required Services

- **PersistenceService**: For saving/loading game state to database
- **CheckoutCalculator**: For generating checkout suggestions
- **StatsCalculator**: For computing player statistics

### Dependency Injection

```dart
class GameEngineImpl implements GameEngine {
  final PersistenceService _persistence;
  final CheckoutCalculator _checkoutCalc;
  final StatsCalculator _statsCalc;

  GameEngineImpl({
    required PersistenceService persistence,
    required CheckoutCalculator checkoutCalculator,
    required StatsCalculator statsCalculator,
  })  : _persistence = persistence,
        _checkoutCalc = checkoutCalculator,
        _statsCalc = statsCalculator;

  // ... implementation
}
```

## Testing Contract

### Unit Tests Required

1. `test_createGame_singlePlayer_success()`
2. `test_createGame_multiplePlayers_success()`
3. `test_createGame_invalidPlayerCount_throwsError()`
4. `test_recordDart_validDart_updatesScore()`
5. `test_recordDart_bustDart_marksAsBust()`
6. `test_recordDart_fourthDart_throwsError()`
7. `test_undoLastDart_success()`
8. `test_undoLastDart_noDarts_throwsError()`
9. `test_completeTurn_advancesToNextPlayer()`
10. `test_completeTurn_bustedTurn_throwsError()`
11. `test_checkFinishAvailable_finishableScore_returnsTrue()`
12. `test_checkFinishAvailable_impossibleScore_returnsFalse()`

### Integration Tests Required

1. `test_completeGame_501_singlePlayer()`
2. `test_completeGame_501_multiPlayer()`
3. `test_bustHandling_scoreGoesNegative()`
4. `test_bustHandling_finishOnSingle()`
5. `test_turnRotation_multiPlayer()`
6. `test_checkoutDetection_170()`

## Performance Contracts

- `createGame()`: < 100ms
- `recordDart()`: < 50ms (excluding database write)
- `validateDart()`: < 10ms (pure calculation)
- `checkFinishAvailable()`: < 100ms (checkout lookup)
- `getGameState()`: < 50ms (database query)

## Thread Safety

All methods are async and safe to call from UI thread. Database operations are handled by PersistenceService which manages its own transaction queue.

---

**Contract version**: 1.0
**Last updated**: 2025-10-23
