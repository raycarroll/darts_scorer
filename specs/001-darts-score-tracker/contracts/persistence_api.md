# Persistence API Contract

**Module**: `lib/services/persistence/`
**Version**: 1.0
**Date**: 2025-10-23

## Overview

The PersistenceService provides data access layer for storing and retrieving game data using SQLite. It manages database lifecycle, migrations, and provides repository pattern for clean data access.

## Public Interface

### DatabaseService Class

Manages database connection and schema.

```dart
abstract class DatabaseService {
  /// Initializes the database connection
  ///
  /// Opens database file, runs migrations if needed
  ///
  /// Returns: Database instance
  ///
  /// Throws: DatabaseException if initialization fails
  Future<Database> initialize();

  /// Closes the database connection
  Future<void> close();

  /// Gets the current database instance
  ///
  /// Throws: StateError if database not initialized
  Database get database;

  /// Gets current database version
  int get version;

  /// Deletes all data from database (for testing/reset)
  Future<void> deleteAll();
}
```

### GameRepository Class

CRUD operations for Game and related entities.

```dart
abstract class GameRepository {
  /// Creates a new game with players
  ///
  /// Parameters:
  ///   - game: Game entity to create
  ///   - players: List of players for the game
  ///
  /// Returns: Created game with generated ID
  ///
  /// Throws:
  ///   - ArgumentError if game ID already exists
  ///   - DatabaseException on database error
  Future<Game> createGame(Game game, List<Player> players);

  /// Gets a game by ID with all related data
  ///
  /// Parameters:
  ///   - gameId: ID of game to retrieve
  ///
  /// Returns: Game entity with ID, or null if not found
  Future<Game?> getGame(String gameId);

  /// Updates game status and metadata
  ///
  /// Parameters:
  ///   - game: Game entity with updated fields
  ///
  /// Returns: Updated game
  ///
  /// Throws:
  ///   - ArgumentError if game not found
  ///   - DatabaseException on database error
  Future<Game> updateGame(Game game);

  /// Deletes a game and all related data (cascades)
  ///
  /// Parameters:
  ///   - gameId: ID of game to delete
  ///
  /// Returns: Number of rows deleted
  Future<int> deleteGame(String gameId);

  /// Gets all games, optionally filtered by status
  ///
  /// Parameters:
  ///   - status: Filter by status (null for all)
  ///   - limit: Maximum number of games to return (null for all)
  ///   - offset: Number of games to skip (for pagination)
  ///
  /// Returns: List of games ordered by createdAt DESC
  Future<List<Game>> getGames({
    GameStatus? status,
    int? limit,
    int? offset,
  });

  /// Gets the currently active game (status = active)
  ///
  /// Returns: Active game, or null if none
  Future<Game?> getActiveGame();

  /// Marks old games for deletion (> 30 days)
  ///
  /// Returns: Number of games deleted
  Future<int> deleteOldGames({int daysToKeep = 30});
}
```

### PlayerRepository Class

CRUD operations for Player entities.

```dart
abstract class PlayerRepository {
  /// Creates a new player
  ///
  /// Parameters:
  ///   - player: Player entity to create
  ///
  /// Returns: Created player with generated ID
  Future<Player> createPlayer(Player player);

  /// Gets a player by ID
  ///
  /// Parameters:
  ///   - playerId: ID of player to retrieve
  ///
  /// Returns: Player entity, or null if not found
  Future<Player?> getPlayer(String playerId);

  /// Updates player data (name, score, isActive)
  ///
  /// Parameters:
  ///   - player: Player entity with updated fields
  ///
  /// Returns: Updated player
  Future<Player> updatePlayer(Player player);

  /// Gets all players for a game
  ///
  /// Parameters:
  ///   - gameId: ID of game
  ///
  /// Returns: List of players ordered by orderPosition
  Future<List<Player>> getPlayersByGame(String gameId);

  /// Updates player's current score
  ///
  /// Parameters:
  ///   - playerId: ID of player
  ///   - newScore: New current score
  ///
  /// Returns: Updated player
  Future<Player> updatePlayerScore(String playerId, int newScore);
}
```

### TurnRepository Class

CRUD operations for Turn and Dart entities.

```dart
abstract class TurnRepository {
  /// Creates a new turn
  ///
  /// Parameters:
  ///   - turn: Turn entity to create
  ///
  /// Returns: Created turn with generated ID
  Future<Turn> createTurn(Turn turn);

  /// Gets a turn by ID with all darts
  ///
  /// Parameters:
  ///   - turnId: ID of turn to retrieve
  ///
  /// Returns: Turn entity with darts, or null if not found
  Future<Turn?> getTurn(String turnId);

  /// Gets all turns for a player
  ///
  /// Parameters:
  ///   - playerId: ID of player
  ///   - limit: Maximum number of turns to return (null for all)
  ///
  /// Returns: List of turns ordered by createdAt DESC
  Future<List<Turn>> getTurnsByPlayer(String playerId, {int? limit});

  /// Gets the current (most recent) turn for a player
  ///
  /// Parameters:
  ///   - playerId: ID of player
  ///
  /// Returns: Most recent turn, or null if no turns
  Future<Turn?> getCurrentTurn(String playerId);

  /// Adds a dart to a turn
  ///
  /// Parameters:
  ///   - turnId: ID of turn
  ///   - dart: Dart entity to add
  ///
  /// Returns: Created dart with generated ID
  ///
  /// Throws:
  ///   - StateError if turn already has 3 darts
  Future<Dart> addDart(String turnId, Dart dart);

  /// Removes the last dart from a turn
  ///
  /// Parameters:
  ///   - turnId: ID of turn
  ///
  /// Returns: Deleted dart, or null if no darts
  Future<Dart?> removeLastDart(String turnId);

  /// Gets all darts for a turn
  ///
  /// Parameters:
  ///   - turnId: ID of turn
  ///
  /// Returns: List of darts ordered by dartNumber
  Future<List<Dart>> getDartsByTurn(String turnId);

  /// Deletes a turn and all its darts
  ///
  /// Parameters:
  ///   - turnId: ID of turn to delete
  ///
  /// Returns: Number of rows deleted
  Future<int> deleteTurn(String turnId);
}
```

## Database Schema

### SQL DDL

```sql
-- Games table
CREATE TABLE games (
  id TEXT PRIMARY KEY,
  game_type TEXT NOT NULL,
  starting_score INTEGER NOT NULL,
  status TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  completed_at INTEGER,
  winner_id TEXT,
  FOREIGN KEY (winner_id) REFERENCES players(id) ON DELETE SET NULL
);

CREATE INDEX idx_games_status ON games(status);
CREATE INDEX idx_games_created_at ON games(created_at DESC);

-- Players table
CREATE TABLE players (
  id TEXT PRIMARY KEY,
  game_id TEXT NOT NULL,
  name TEXT NOT NULL,
  order_position INTEGER NOT NULL,
  current_score INTEGER NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
  UNIQUE(game_id, order_position)
);

CREATE INDEX idx_players_game_id ON players(game_id);
CREATE INDEX idx_players_order ON players(game_id, order_position);

-- Turns table
CREATE TABLE turns (
  id TEXT PRIMARY KEY,
  player_id TEXT NOT NULL,
  round_number INTEGER NOT NULL,
  turn_number INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE
);

CREATE INDEX idx_turns_player_id ON turns(player_id);
CREATE INDEX idx_turns_created_at ON turns(created_at DESC);

-- Darts table
CREATE TABLE darts (
  id TEXT PRIMARY KEY,
  turn_id TEXT NOT NULL,
  dart_number INTEGER NOT NULL,
  zone INTEGER NOT NULL,
  multiplier TEXT NOT NULL,
  points INTEGER NOT NULL,
  FOREIGN KEY (turn_id) REFERENCES turns(id) ON DELETE CASCADE,
  UNIQUE(turn_id, dart_number)
);

CREATE INDEX idx_darts_turn_id ON darts(turn_id);
```

## Data Mapping

### Entity to Database

#### Game Mapping

```dart
Map<String, dynamic> _gameToMap(Game game) {
  return {
    'id': game.id,
    'game_type': game.gameType.name,  // 'fiveOhOne', 'threeOhOne', etc.
    'starting_score': game.startingScore,
    'status': game.status.name,  // 'active', 'completed', 'abandoned'
    'created_at': game.createdAt.millisecondsSinceEpoch,
    'completed_at': game.completedAt?.millisecondsSinceEpoch,
    'winner_id': game.winnerId,
  };
}

Game _mapToGame(Map<String, dynamic> map) {
  return Game(
    id: map['id'] as String,
    gameType: GameType.values.byName(map['game_type'] as String),
    startingScore: map['starting_score'] as int,
    status: GameStatus.values.byName(map['status'] as String),
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    completedAt: map['completed_at'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['completed_at'] as int)
        : null,
    winnerId: map['winner_id'] as String?,
  );
}
```

#### Player Mapping

```dart
Map<String, dynamic> _playerToMap(Player player) {
  return {
    'id': player.id,
    'game_id': player.gameId,
    'name': player.name,
    'order_position': player.orderPosition,
    'current_score': player.currentScore,
    'is_active': player.isActive ? 1 : 0,  // SQLite boolean
  };
}

Player _mapToPlayer(Map<String, dynamic> map) {
  return Player(
    id: map['id'] as String,
    gameId: map['game_id'] as String,
    name: map['name'] as String,
    orderPosition: map['order_position'] as int,
    currentScore: map['current_score'] as int,
    isActive: map['is_active'] == 1,
  );
}
```

#### Turn Mapping

```dart
Map<String, dynamic> _turnToMap(Turn turn) {
  return {
    'id': turn.id,
    'player_id': turn.playerId,
    'round_number': turn.roundNumber,
    'turn_number': turn.turnNumber,
    'created_at': turn.createdAt.millisecondsSinceEpoch,
  };
}

Turn _mapToTurn(Map<String, dynamic> map) {
  return Turn(
    id: map['id'] as String,
    playerId: map['player_id'] as String,
    roundNumber: map['round_number'] as int,
    turnNumber: map['turn_number'] as int,
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
  );
}
```

#### Dart Mapping

```dart
Map<String, dynamic> _dartToMap(Dart dart) {
  return {
    'id': dart.id,
    'turn_id': dart.turnId,
    'dart_number': dart.dartNumber,
    'zone': dart.zone,
    'multiplier': dart.multiplier.name,  // 'single', 'double', 'triple', etc.
    'points': dart.points,
  };
}

Dart _mapToDart(Map<String, dynamic> map) {
  return Dart(
    id: map['id'] as String,
    turnId: map['turn_id'] as String,
    dartNumber: map['dart_number'] as int,
    zone: map['zone'] as int,
    multiplier: Multiplier.values.byName(map['multiplier'] as String),
    points: map['points'] as int,
  );
}
```

## Transaction Management

### Atomic Operations

```dart
/// Creates game and players atomically
Future<Game> createGame(Game game, List<Player> players) async {
  return await _db.transaction((txn) async {
    // Insert game
    await txn.insert('games', _gameToMap(game));

    // Insert all players
    for (var player in players) {
      await txn.insert('players', _playerToMap(player));
    }

    return game;
  });
}

/// Deletes game and cascades to players, turns, darts
Future<int> deleteGame(String gameId) async {
  // CASCADE delete is handled by foreign key constraints
  return await _db.delete(
    'games',
    where: 'id = ?',
    whereArgs: [gameId],
  );
}
```

## Migration Strategy

### Version Management

```dart
class DatabaseService {
  static const int _currentVersion = 1;

  Future<Database> initialize() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'darts_scorer.db');

    return await openDatabase(
      path,
      version: _currentVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create all tables
    await db.execute('''
      CREATE TABLE games (
        id TEXT PRIMARY KEY,
        game_type TEXT NOT NULL,
        starting_score INTEGER NOT NULL,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        completed_at INTEGER,
        winner_id TEXT,
        FOREIGN KEY (winner_id) REFERENCES players(id) ON DELETE SET NULL
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_games_status ON games(status)');
    await db.execute('CREATE INDEX idx_games_created_at ON games(created_at DESC)');

    // Create players table...
    // Create turns table...
    // Create darts table...
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Run migrations sequentially
    if (oldVersion < 2) {
      // Migration 1 -> 2
      await db.execute('ALTER TABLE games ADD COLUMN double_in INTEGER DEFAULT 0');
    }

    if (oldVersion < 3) {
      // Migration 2 -> 3
      await db.execute('CREATE INDEX idx_new_column ON games(new_column)');
    }
  }
}
```

## Error Handling

### Exceptions

```dart
/// Base exception for database errors
class DatabaseException implements Exception {
  final String message;
  final dynamic cause;

  DatabaseException(this.message, [this.cause]);

  @override
  String toString() => 'DatabaseException: $message${cause != null ? " ($cause)" : ""}';
}

/// Entity not found exception
class EntityNotFoundException extends DatabaseException {
  final String entityType;
  final String entityId;

  EntityNotFoundException(this.entityType, this.entityId)
      : super('$entityType not found: $entityId');
}

/// Constraint violation exception
class ConstraintViolationException extends DatabaseException {
  final String constraint;

  ConstraintViolationException(this.constraint, [dynamic cause])
      : super('Constraint violation: $constraint', cause);
}
```

### Error Scenarios

| Error | Exception | Handling |
|-------|-----------|----------|
| Game not found | `EntityNotFoundException` | Return null from getGame() |
| Duplicate player order | `ConstraintViolationException` | Validate before insert |
| Foreign key violation | `ConstraintViolationException` | Check references exist |
| Database locked | `DatabaseException` | Retry with backoff |
| Disk full | `DatabaseException` | Alert user, cleanup old data |

## Performance Considerations

### Indexes

All foreign keys are indexed for fast joins:
- `idx_games_status`: Fast filtering by status
- `idx_games_created_at`: Fast ordering by date
- `idx_players_game_id`: Fast player lookups by game
- `idx_turns_player_id`: Fast turn lookups by player
- `idx_darts_turn_id`: Fast dart lookups by turn

### Query Optimization

```dart
/// Efficient query with single join
Future<Game> getGameWithPlayers(String gameId) async {
  final db = await database;

  // Get game
  final gameMaps = await db.query(
    'games',
    where: 'id = ?',
    whereArgs: [gameId],
  );

  if (gameMaps.isEmpty) return null;

  // Get players (uses index)
  final playerMaps = await db.query(
    'players',
    where: 'game_id = ?',
    whereArgs: [gameId],
    orderBy: 'order_position ASC',
  );

  return Game(...);  // Construct with players
}
```

### Batch Operations

```dart
/// Insert multiple darts efficiently
Future<void> addDarts(List<Dart> darts) async {
  final db = await database;

  await db.transaction((txn) async {
    final batch = txn.batch();

    for (var dart in darts) {
      batch.insert('darts', _dartToMap(dart));
    }

    await batch.commit(noResult: true);
  });
}
```

## Testing Contract

### Unit Tests Required

1. `test_createGame_success()`
2. `test_createGame_withPlayers_atomicTransaction()`
3. `test_getGame_exists_returnsGame()`
4. `test_getGame_notFound_returnsNull()`
5. `test_updateGame_success()`
6. `test_deleteGame_cascadesDeletes()`
7. `test_getGames_filterByStatus()`
8. `test_getActiveGame_returnsActiveOnly()`
9. `test_deleteOldGames_removes30DayOld()`
10. `test_createPlayer_success()`
11. `test_updatePlayerScore_success()`
12. `test_addDart_success()`
13. `test_addDart_fourthDart_throwsError()`
14. `test_removeLastDart_success()`

### Integration Tests Required

1. `test_fullGameFlow_createToComplete()`
2. `test_multipleGames_isolation()`
3. `test_migration_v1tov2_success()`
4. `test_foreignKeyConstraints_enforced()`
5. `test_transaction_rollback_onError()`

## Performance Contracts

- `initialize()`: < 200ms (including migrations)
- `createGame()`: < 50ms
- `getGame()`: < 30ms
- `addDart()`: < 20ms
- `query with joins`: < 50ms
- `deleteOldGames()`: < 500ms (bulk delete)

## Thread Safety

All database operations are async and use sqflite's internal locking mechanism. Multiple concurrent reads are safe. Writes are serialized automatically by sqflite.

---

**Contract version**: 1.0
**Last updated**: 2025-10-23
