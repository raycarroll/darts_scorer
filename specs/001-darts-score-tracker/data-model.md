# Data Model: Darts Score Tracker

**Feature**: 001-darts-score-tracker
**Date**: 2025-10-23
**Phase**: Phase 1 - Design

## Overview

This document defines the complete data model for the darts scoring application, including entities, relationships, validation rules, and database schema.

## Entity-Relationship Diagram

```
┌─────────────┐
│  GameType   │
│  (enum)     │
└──────┬──────┘
       │
       │ 1
       │
       │ *
┌──────▼──────────┐         ┌──────────────┐
│      Game       │ 1     * │    Player    │
│                 ├─────────┤              │
│  - id           │         │  - id        │
│  - gameType     │         │  - gameId    │
│  - startingScore│         │  - name      │
│  - status       │         │  - order     │
│  - createdAt    │         │  - isActive  │
│  - completedAt  │         │              │
└────────┬────────┘         └──────┬───────┘
         │                         │
         │ 1                       │ 1
         │                         │
         │ *                       │ *
    ┌────▼────────┐         ┌──────▼──────┐
    │ GameState   │         │    Turn     │
    │             │         │             │
    │ - currentRd │         │ - id        │
    │ - currentPly│         │ - playerId  │
    │             │         │ - roundNum  │
    │             │         │ - turnNum   │
    └─────────────┘         │ - createdAt │
                            └──────┬──────┘
                                   │
                                   │ 1
                                   │
                                   │ *
                            ┌──────▼──────┐
                            │    Dart     │
                            │             │
                            │ - id        │
                            │ - turnId    │
                            │ - dartNum   │
                            │ - zone      │
                            │ - multiplier│
                            │ - points    │
                            └─────────────┘

┌──────────────────────┐
│ CheckoutSuggestion   │
│  (computed)          │
│                      │
│  - score             │
│  - darts[]           │
│  - description       │
│  - difficulty        │
└──────────────────────┘
```

## Core Entities

### 1. Game

Represents a complete darts match.

**Dart Class**:
```dart
class Game {
  final String id;              // UUID
  final GameType gameType;      // Enum: fiveOhOne, threeOhOne, cricket, aroundClock
  final int startingScore;      // e.g., 501, 301
  final GameStatus status;      // Enum: active, completed, abandoned
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? winnerId;       // Reference to Player.id

  Game({
    required this.id,
    required this.gameType,
    required this.startingScore,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.winnerId,
  });
}
```

**Database Schema (SQLite)**:
```sql
CREATE TABLE games (
  id TEXT PRIMARY KEY,
  game_type TEXT NOT NULL,           -- 'five_oh_one', 'three_oh_one', 'cricket', 'around_clock'
  starting_score INTEGER NOT NULL,
  status TEXT NOT NULL,              -- 'active', 'completed', 'abandoned'
  created_at INTEGER NOT NULL,       -- Unix timestamp (milliseconds)
  completed_at INTEGER,              -- Unix timestamp (milliseconds)
  winner_id TEXT,                    -- Foreign key to players.id
  FOREIGN KEY (winner_id) REFERENCES players(id) ON DELETE SET NULL
);

CREATE INDEX idx_games_status ON games(status);
CREATE INDEX idx_games_created_at ON games(created_at DESC);
```

**Validation Rules**:
- `id`: Must be valid UUID
- `gameType`: Must be one of: fiveOhOne, threeOhOne, cricket, aroundClock
- `startingScore`: Must match gameType (501 for fiveOhOne, 301 for threeOhOne, 0 for others)
- `status`: Must be one of: active, completed, abandoned
- `createdAt`: Must be valid timestamp
- `completedAt`: Must be null if status is active, non-null if completed
- `winnerId`: Must reference existing player if non-null

**Business Rules**:
- Only one game can be active at a time per device
- Completed games cannot be modified
- Game must have at least 1 player before starting

---

### 2. Player

Represents a participant in a game.

**Dart Class**:
```dart
class Player {
  final String id;              // UUID
  final String gameId;          // Foreign key to Game.id
  final String name;            // Display name
  final int orderPosition;      // Turn order (0, 1, 2, 3)
  final int currentScore;       // Current remaining score
  final bool isActive;          // Is this player still in the game?

  Player({
    required this.id,
    required this.gameId,
    required this.name,
    required this.orderPosition,
    required this.currentScore,
    this.isActive = true,
  });

  // Computed properties (not stored)
  double get average3Dart => _calculateAverage();
  double get averagePerDart => average3Dart / 3.0;
  int get dartsThrown => _countDarts();
  int get checkoutAttempts => _countCheckoutAttempts();
  int get checkoutSuccesses => _countCheckoutSuccesses();
  double get checkoutPercentage => checkoutSuccesses / checkoutAttempts;
}
```

**Database Schema (SQLite)**:
```sql
CREATE TABLE players (
  id TEXT PRIMARY KEY,
  game_id TEXT NOT NULL,
  name TEXT NOT NULL,
  order_position INTEGER NOT NULL,
  current_score INTEGER NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1,  -- SQLite boolean (0 or 1)
  FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
  UNIQUE(game_id, order_position)
);

CREATE INDEX idx_players_game_id ON players(game_id);
CREATE INDEX idx_players_order ON players(game_id, order_position);
```

**Validation Rules**:
- `id`: Must be valid UUID
- `gameId`: Must reference existing game
- `name`: Must be 1-20 characters, non-empty
- `orderPosition`: Must be 0-3 (max 4 players), unique per game
- `currentScore`: Must be >= 0
- `isActive`: Boolean (stored as 0 or 1 in SQLite)

**Business Rules**:
- Minimum 1 player, maximum 4 players per game
- Player names must be unique within a game
- Player order determines turn rotation
- Current score updated after each turn
- Player marked inactive if they finish the game (multi-player)

---

### 3. Turn

Represents one player's turn (up to 3 darts).

**Dart Class**:
```dart
class Turn {
  final String id;              // UUID
  final String playerId;        // Foreign key to Player.id
  final int roundNumber;        // Game round (1, 2, 3, ...)
  final int turnNumber;         // Player's turn number (1, 2, 3, ...)
  final DateTime createdAt;

  // Computed from darts
  int get totalScore => _sumDartScores();
  int get dartsThrown => _countDarts();
  bool get isBust => _checkBust();

  Turn({
    required this.id,
    required this.playerId,
    required this.roundNumber,
    required this.turnNumber,
    required this.createdAt,
  });
}
```

**Database Schema (SQLite)**:
```sql
CREATE TABLE turns (
  id TEXT PRIMARY KEY,
  player_id TEXT NOT NULL,
  round_number INTEGER NOT NULL,
  turn_number INTEGER NOT NULL,
  created_at INTEGER NOT NULL,  -- Unix timestamp (milliseconds)
  FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE
);

CREATE INDEX idx_turns_player_id ON turns(player_id);
CREATE INDEX idx_turns_created_at ON turns(created_at DESC);
```

**Validation Rules**:
- `id`: Must be valid UUID
- `playerId`: Must reference existing player
- `roundNumber`: Must be >= 1
- `turnNumber`: Must be >= 1
- `createdAt`: Must be valid timestamp

**Business Rules**:
- A turn can have 0-3 darts (0 if turn just created)
- Turn number increments for each player independently
- Round number increments when all players complete their turn
- Turn cannot be modified after next player starts their turn

---

### 4. Dart

Represents a single dart throw.

**Dart Class**:
```dart
class Dart {
  final String id;              // UUID
  final String turnId;          // Foreign key to Turn.id
  final int dartNumber;         // 1, 2, or 3
  final int zone;               // 0 (miss), 1-20, 25 (bull)
  final Multiplier multiplier;  // Enum: single, double, triple, outerBull, innerBull
  final int points;             // Computed: zone * multiplier value

  Dart({
    required this.id,
    required this.turnId,
    required this.dartNumber,
    required this.zone,
    required this.multiplier,
    required this.points,
  });

  // Factory for common dart types
  factory Dart.single(String id, String turnId, int dartNum, int zone) {
    return Dart(
      id: id,
      turnId: turnId,
      dartNumber: dartNum,
      zone: zone,
      multiplier: Multiplier.single,
      points: zone * 1,
    );
  }

  factory Dart.double(String id, String turnId, int dartNum, int zone) {
    return Dart(
      id: id,
      turnId: turnId,
      dartNumber: dartNum,
      zone: zone,
      multiplier: Multiplier.double,
      points: zone * 2,
    );
  }

  factory Dart.triple(String id, String turnId, int dartNum, int zone) {
    return Dart(
      id: id,
      turnId: turnId,
      dartNumber: dartNum,
      zone: zone,
      multiplier: Multiplier.triple,
      points: zone * 3,
    );
  }

  factory Dart.outerBull(String id, String turnId, int dartNum) {
    return Dart(
      id: id,
      turnId: turnId,
      dartNumber: dartNum,
      zone: 25,
      multiplier: Multiplier.outerBull,
      points: 25,
    );
  }

  factory Dart.innerBull(String id, String turnId, int dartNum) {
    return Dart(
      id: id,
      turnId: turnId,
      dartNumber: dartNum,
      zone: 25,
      multiplier: Multiplier.innerBull,
      points: 50,
    );
  }

  factory Dart.miss(String id, String turnId, int dartNum) {
    return Dart(
      id: id,
      turnId: turnId,
      dartNumber: dartNum,
      zone: 0,
      multiplier: Multiplier.single,
      points: 0,
    );
  }
}
```

**Database Schema (SQLite)**:
```sql
CREATE TABLE darts (
  id TEXT PRIMARY KEY,
  turn_id TEXT NOT NULL,
  dart_number INTEGER NOT NULL,      -- 1, 2, or 3
  zone INTEGER NOT NULL,             -- 0 (miss), 1-20, 25 (bull)
  multiplier TEXT NOT NULL,          -- 'single', 'double', 'triple', 'outer_bull', 'inner_bull'
  points INTEGER NOT NULL,           -- Computed but stored for query performance
  FOREIGN KEY (turn_id) REFERENCES turns(id) ON DELETE CASCADE,
  UNIQUE(turn_id, dart_number)
);

CREATE INDEX idx_darts_turn_id ON darts(turn_id);
```

**Validation Rules**:
- `id`: Must be valid UUID
- `turnId`: Must reference existing turn
- `dartNumber`: Must be 1, 2, or 3
- `zone`: Must be 0 (miss), 1-20, or 25 (bull)
- `multiplier`: Must be one of: single, double, triple, outerBull, innerBull
- `points`: Must equal zone × multiplier value (or 25/50 for bulls)

**Multiplier Values**:
- `single`: ×1
- `double`: ×2
- `triple`: ×3
- `outerBull`: 25 points (zone 25, ×1)
- `innerBull`: 50 points (zone 25, ×2)

**Business Rules**:
- Maximum 3 darts per turn
- Dart numbers must be sequential (1, then 2, then 3)
- Cannot add dart 2 without dart 1
- Points are computed from zone and multiplier
- Bull's eye: zone=25, multiplier determines 25 or 50

---

### 5. GameType (Enum)

Defines the type of darts game being played.

**Dart Enum**:
```dart
enum GameType {
  fiveOhOne('501', 501),
  threeOhOne('301', 301),
  cricket('Cricket', 0),
  aroundClock('Around the Clock', 0);

  const GameType(this.displayName, this.startingScore);

  final String displayName;
  final int startingScore;
}
```

**Values**:
- `fiveOhOne`: Standard 501 game, countdown from 501, double-out
- `threeOhOne`: Shorter 301 game, countdown from 301, double-out
- `cricket`: Mark-based game on numbers 15-20 and bulls
- `aroundClock`: Sequential game, hit 1-20 in order then bullseye

**Game-Specific Rules**:

#### 501 / 301 Rules
- Start at 501 or 301
- Subtract dart scores from remaining
- Must finish on a double
- Bust if: score goes below 0, equals 1, or finishes on non-double
- Winner: First to reach exactly 0 with double finish

#### Cricket Rules
- Target numbers: 15, 16, 17, 18, 19, 20, Bulls
- Score "marks" on each number (1 mark = single, 2 marks = double, 3 marks = triple)
- After 3 marks, number is "closed"
- Can score points on opponent's open numbers after closing your own
- Winner: First to close all numbers with highest score

#### Around the Clock Rules
- Must hit 1, then 2, then 3, ..., then 20 in sequence
- After 20, must hit bullseye to finish
- Any multiplier counts (single, double, or triple)
- Winner: First to complete 1-20 and bull sequence

---

### 6. CheckoutSuggestion

Represents a valid checkout combination (computed, not stored).

**Dart Class**:
```dart
class CheckoutSuggestion {
  final int score;                    // Score to finish from (2-170)
  final List<DartSpec> darts;         // 1-3 darts to finish
  final String description;           // Human-readable (e.g., "D20", "T20-D20")
  final int difficulty;               // 1 (easy) to 5 (hard)

  CheckoutSuggestion({
    required this.score,
    required this.darts,
    required this.description,
    required this.difficulty,
  });

  int get dartsRequired => darts.length;
  bool get isSingleDart => darts.length == 1;
  bool get isDoubleDart => darts.length == 2;
  bool get isThreeDart => darts.length == 3;
}

class DartSpec {
  final int zone;              // 1-20 or 25
  final Multiplier multiplier; // single, double, triple, innerBull, outerBull

  DartSpec(this.zone, this.multiplier);

  int get points => multiplier == Multiplier.innerBull ? 50 :
                   multiplier == Multiplier.outerBull ? 25 :
                   zone * _multiplierValue(multiplier);

  String get notation {
    switch (multiplier) {
      case Multiplier.single: return '$zone';
      case Multiplier.double: return 'D$zone';
      case Multiplier.triple: return 'T$zone';
      case Multiplier.innerBull: return 'Bull';
      case Multiplier.outerBull: return '25';
    }
  }
}
```

**Checkout Database** (in-memory Map):
```dart
// Example entries
final checkoutDatabase = {
  40: [
    CheckoutSuggestion(40, [DartSpec(20, double)], 'D20', 1),
    CheckoutSuggestion(40, [DartSpec(10, double)], 'D10', 2),
  ],
  50: [
    CheckoutSuggestion(50, [DartSpec(25, innerBull)], 'Bull', 1),
    CheckoutSuggestion(50, [DartSpec(10, single), DartSpec(20, double)], '10-D20', 2),
  ],
  170: [
    CheckoutSuggestion(170, [
      DartSpec(20, triple),
      DartSpec(20, triple),
      DartSpec(25, innerBull)
    ], 'T20-T20-Bull', 5),
  ],
  // ... entries for all 2-170 valid finishes
};

// Impossible finishes (will return empty list)
final impossibleFinishes = [
  1,    // Cannot finish on 1 (must be double)
  169,  // Impossible (odd number > 50, requires single+double but no valid combo)
  168,  // Impossible
  166,  // Impossible
  165,  // Impossible
  163,  // Impossible
  162,  // Impossible
  159,  // Impossible
];
```

**Validation Rules**:
- Score must be 2-170
- Final dart must be a double (for 501/301)
- Total of dart points must equal score
- Maximum 3 darts

**Difficulty Rating**:
- **1 (Easy)**: Single dart double (D20, D25)
- **2 (Moderate)**: Two dart finish with big doubles
- **3 (Challenging)**: Two dart with small doubles or three dart with big targets
- **4 (Hard)**: Three dart with mixed targets
- **5 (Expert)**: Complex three dart (e.g., T20-T20-Bull for 170)

---

## Enumerations

### GameStatus
```dart
enum GameStatus {
  active,      // Game in progress
  completed,   // Game finished with winner
  abandoned,   // Game cancelled/quit
}
```

### Multiplier
```dart
enum Multiplier {
  single,      // ×1 (1-20)
  double,      // ×2 (1-20)
  triple,      // ×3 (1-20)
  outerBull,   // 25 points (outer bull)
  innerBull,   // 50 points (inner bull / double bull)
}
```

---

## Relationships

### One-to-Many Relationships

1. **Game → Players** (1:N)
   - One game has multiple players (1-4)
   - Each player belongs to one game
   - Cascade delete: Deleting game deletes all players

2. **Player → Turns** (1:N)
   - One player has multiple turns
   - Each turn belongs to one player
   - Cascade delete: Deleting player deletes all turns

3. **Turn → Darts** (1:N)
   - One turn has multiple darts (0-3)
   - Each dart belongs to one turn
   - Cascade delete: Deleting turn deletes all darts

### Lookup Relationships

1. **Game → GameType** (N:1 enum lookup)
   - Many games can have same game type
   - Game type is enumeration, not stored entity

2. **Game → Winner** (N:1 optional)
   - Many games can have same winner
   - Winner is reference to Player.id
   - Set to null if winner deleted

---

## Computed Fields & Derivations

### Player Statistics

Computed from Turn and Dart data:

```dart
class PlayerStats {
  final Player player;

  // Dart counting
  int get totalDarts => _queryDartCount();
  int get totalTurns => _queryTurnCount();

  // Scoring averages
  int get totalPoints => _queryTotalPoints();
  double get average3Dart => totalPoints / totalTurns;
  double get averagePerDart => totalPoints / totalDarts;

  // High scores
  int get highestTurn => _queryMaxTurnScore();
  int get highest3Dart => _queryMax3DartScore();

  // Checkout statistics
  int get checkoutAttempts => _countCheckoutAttempts();
  int get checkoutSuccesses => _countCheckoutSuccesses();
  double get checkoutPercentage =>
      checkoutAttempts > 0 ? (checkoutSuccesses / checkoutAttempts) * 100 : 0.0;

  // Marks (for Cricket)
  Map<int, int> get marks => _calculateMarks(); // {15: 3, 16: 2, ...}
}
```

### Game State

Computed from current turn/player:

```dart
class GameState {
  final Game game;

  Player get currentPlayer => _getCurrentPlayer();
  int get currentRound => _getCurrentRound();
  bool get isFinishable => _checkFinishable();
  List<CheckoutSuggestion> get checkouts => _getCheckouts();
}
```

---

## Database Indexes

For optimal query performance:

```sql
-- Game queries
CREATE INDEX idx_games_status ON games(status);
CREATE INDEX idx_games_created_at ON games(created_at DESC);

-- Player queries
CREATE INDEX idx_players_game_id ON players(game_id);
CREATE INDEX idx_players_order ON players(game_id, order_position);

-- Turn queries
CREATE INDEX idx_turns_player_id ON turns(player_id);
CREATE INDEX idx_turns_created_at ON turns(created_at DESC);

-- Dart queries
CREATE INDEX idx_darts_turn_id ON darts(turn_id);
```

---

## Sample Data

### Example Game (501, 2 players)

```
Game:
  id: "game-001"
  gameType: fiveOhOne
  startingScore: 501
  status: active
  createdAt: 2025-10-23T10:00:00Z

Players:
  Player 1:
    id: "player-001"
    gameId: "game-001"
    name: "Alice"
    orderPosition: 0
    currentScore: 381

  Player 2:
    id: "player-002"
    gameId: "game-001"
    name: "Bob"
    orderPosition: 1
    currentScore: 421

Turns:
  Turn 1 (Alice, Round 1):
    id: "turn-001"
    playerId: "player-001"
    roundNumber: 1
    turnNumber: 1
    Darts:
      Dart 1: T20 (60 points)
      Dart 2: T20 (60 points)
      Dart 3: Miss (0 points)
    Total: 120 points

  Turn 2 (Bob, Round 1):
    id: "turn-002"
    playerId: "player-002"
    roundNumber: 1
    turnNumber: 1
    Darts:
      Dart 1: T20 (60 points)
      Dart 2: S20 (20 points)
      Dart 3: Miss (0 points)
    Total: 80 points
```

---

## Migration Strategy

### Version 1.0 (Initial Release)

Initial schema as documented above.

### Future Migrations

**Version 1.1** - Add game settings:
```sql
ALTER TABLE games ADD COLUMN double_in INTEGER DEFAULT 0;  -- Require double to start
ALTER TABLE games ADD COLUMN cricket_variant TEXT DEFAULT 'standard';
```

**Version 1.2** - Add statistics cache:
```sql
CREATE TABLE player_stats (
  player_id TEXT PRIMARY KEY,
  total_darts INTEGER,
  total_points INTEGER,
  highest_turn INTEGER,
  checkout_attempts INTEGER,
  checkout_successes INTEGER,
  updated_at INTEGER,
  FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE
);
```

---

## Validation Summary

| Entity | Required Fields | Constraints |
|--------|----------------|-------------|
| Game | id, gameType, startingScore, status, createdAt | status in {active, completed, abandoned} |
| Player | id, gameId, name, orderPosition, currentScore | 1-4 players per game, unique order |
| Turn | id, playerId, roundNumber, turnNumber, createdAt | roundNumber >= 1, turnNumber >= 1 |
| Dart | id, turnId, dartNumber, zone, multiplier, points | dartNumber in {1,2,3}, zone in {0,1-20,25} |

---

**Data model completed**: 2025-10-23
**Next**: Create API contracts in `contracts/` directory
