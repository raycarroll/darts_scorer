import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

abstract class DatabaseService {
  Future<Database> initialize();
  Future<void> close();
  Database get database;
  int get version;
  Future<void> deleteAll();
}

class DatabaseServiceImpl implements DatabaseService {
  Database? _database;
  static const int _currentVersion = 1;

  @override
  int get version => _currentVersion;

  @override
  Database get database {
    if (_database == null) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
    return _database!;
  }

  @override
  Future<Database> initialize() async {
    if (_database != null) {
      return _database!;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'darts_scorer.db');

    _database = await openDatabase(
      path,
      version: _currentVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );

    return _database!;
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create games table
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

    await db.execute('CREATE INDEX idx_games_status ON games(status)');
    await db.execute('CREATE INDEX idx_games_created_at ON games(created_at DESC)');

    // Create players table
    await db.execute('''
      CREATE TABLE players (
        id TEXT PRIMARY KEY,
        game_id TEXT NOT NULL,
        name TEXT NOT NULL,
        order_position INTEGER NOT NULL,
        current_score INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE,
        UNIQUE(game_id, order_position)
      )
    ''');

    await db.execute('CREATE INDEX idx_players_game_id ON players(game_id)');
    await db.execute('CREATE INDEX idx_players_order ON players(game_id, order_position)');

    // Create turns table
    await db.execute('''
      CREATE TABLE turns (
        id TEXT PRIMARY KEY,
        player_id TEXT NOT NULL,
        round_number INTEGER NOT NULL,
        turn_number INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_turns_player_id ON turns(player_id)');
    await db.execute('CREATE INDEX idx_turns_created_at ON turns(created_at DESC)');

    // Create darts table
    await db.execute('''
      CREATE TABLE darts (
        id TEXT PRIMARY KEY,
        turn_id TEXT NOT NULL,
        dart_number INTEGER NOT NULL,
        zone INTEGER NOT NULL,
        multiplier TEXT NOT NULL,
        points INTEGER NOT NULL,
        FOREIGN KEY (turn_id) REFERENCES turns(id) ON DELETE CASCADE,
        UNIQUE(turn_id, dart_number)
      )
    ''');

    await db.execute('CREATE INDEX idx_darts_turn_id ON darts(turn_id)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future migrations here
  }

  @override
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  @override
  Future<void> deleteAll() async {
    final db = database;
    await db.delete('darts');
    await db.delete('turns');
    await db.delete('players');
    await db.delete('games');
  }
}
