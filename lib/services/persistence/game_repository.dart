import 'package:darts_scorer/models/game.dart';
import 'package:darts_scorer/models/game_status.dart';
import 'package:darts_scorer/models/player.dart';
import 'database_service.dart';

abstract class GameRepository {
  Future<Game> createGame(Game game, List<Player> players);
  Future<Game?> getGame(String gameId);
  Future<Game> updateGame(Game game);
  Future<int> deleteGame(String gameId);
  Future<List<Game>> getGames({GameStatus? status, int? limit, int? offset});
  Future<Game?> getActiveGame();
  Future<int> deleteOldGames({int daysToKeep = 30});
}

class GameRepositoryImpl implements GameRepository {
  final DatabaseService _dbService;

  GameRepositoryImpl(this._dbService);

  @override
  Future<Game> createGame(Game game, List<Player> players) async {
    final db = _dbService.database;

    await db.transaction((txn) async {
      // Insert game
      await txn.insert('games', game.toMap());

      // Insert all players
      for (final player in players) {
        await txn.insert('players', player.toMap());
      }
    });

    return game;
  }

  @override
  Future<Game?> getGame(String gameId) async {
    final db = _dbService.database;

    final results = await db.query(
      'games',
      where: 'id = ?',
      whereArgs: [gameId],
    );

    if (results.isEmpty) {
      return null;
    }

    return Game.fromMap(results.first);
  }

  @override
  Future<Game> updateGame(Game game) async {
    final db = _dbService.database;

    await db.update(
      'games',
      game.toMap(),
      where: 'id = ?',
      whereArgs: [game.id],
    );

    return game;
  }

  @override
  Future<int> deleteGame(String gameId) async {
    final db = _dbService.database;

    return await db.delete(
      'games',
      where: 'id = ?',
      whereArgs: [gameId],
    );
  }

  @override
  Future<List<Game>> getGames({
    GameStatus? status,
    int? limit,
    int? offset,
  }) async {
    final db = _dbService.database;

    final results = await db.query(
      'games',
      where: status != null ? 'status = ?' : null,
      whereArgs: status != null ? [status.name] : null,
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );

    return results.map((map) => Game.fromMap(map)).toList();
  }

  @override
  Future<Game?> getActiveGame() async {
    final db = _dbService.database;

    final results = await db.query(
      'games',
      where: 'status = ?',
      whereArgs: [GameStatus.active.name],
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return Game.fromMap(results.first);
  }

  @override
  Future<int> deleteOldGames({int daysToKeep = 30}) async {
    final db = _dbService.database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

    return await db.delete(
      'games',
      where: 'created_at < ? AND status != ?',
      whereArgs: [cutoffDate.millisecondsSinceEpoch, GameStatus.active.name],
    );
  }
}
