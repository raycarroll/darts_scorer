import 'package:darts_scorer/models/player.dart';
import 'database_service.dart';

abstract class PlayerRepository {
  Future<Player> createPlayer(Player player);
  Future<Player?> getPlayer(String playerId);
  Future<Player> updatePlayer(Player player);
  Future<List<Player>> getPlayersByGame(String gameId);
  Future<Player> updatePlayerScore(String playerId, int newScore);
}

class PlayerRepositoryImpl implements PlayerRepository {
  final DatabaseService _dbService;

  PlayerRepositoryImpl(this._dbService);

  @override
  Future<Player> createPlayer(Player player) async {
    final db = _dbService.database;
    await db.insert('players', player.toMap());
    return player;
  }

  @override
  Future<Player?> getPlayer(String playerId) async {
    final db = _dbService.database;

    final results = await db.query(
      'players',
      where: 'id = ?',
      whereArgs: [playerId],
    );

    if (results.isEmpty) {
      return null;
    }

    return Player.fromMap(results.first);
  }

  @override
  Future<Player> updatePlayer(Player player) async {
    final db = _dbService.database;

    await db.update(
      'players',
      player.toMap(),
      where: 'id = ?',
      whereArgs: [player.id],
    );

    return player;
  }

  @override
  Future<List<Player>> getPlayersByGame(String gameId) async {
    final db = _dbService.database;

    final results = await db.query(
      'players',
      where: 'game_id = ?',
      whereArgs: [gameId],
      orderBy: 'order_position ASC',
    );

    return results.map((map) => Player.fromMap(map)).toList();
  }

  @override
  Future<Player> updatePlayerScore(String playerId, int newScore) async {
    final db = _dbService.database;

    await db.update(
      'players',
      {'current_score': newScore},
      where: 'id = ?',
      whereArgs: [playerId],
    );

    final player = await getPlayer(playerId);
    return player!;
  }
}
