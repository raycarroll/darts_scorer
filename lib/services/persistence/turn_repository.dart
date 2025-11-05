import 'package:darts_scorer/models/turn.dart';
import 'package:darts_scorer/models/dart.dart';
import 'database_service.dart';

abstract class TurnRepository {
  Future<Turn> createTurn(Turn turn);
  Future<Turn?> getTurn(String turnId);
  Future<List<Turn>> getTurnsByPlayer(String playerId, {int? limit});
  Future<Turn?> getCurrentTurn(String playerId);
  Future<Dart> addDart(String turnId, Dart dart);
  Future<Dart?> removeLastDart(String turnId);
  Future<List<Dart>> getDartsByTurn(String turnId);
  Future<int> deleteTurn(String turnId);
}

class TurnRepositoryImpl implements TurnRepository {
  final DatabaseService _dbService;

  TurnRepositoryImpl(this._dbService);

  @override
  Future<Turn> createTurn(Turn turn) async {
    final db = _dbService.database;
    await db.insert('turns', turn.toMap());
    return turn;
  }

  @override
  Future<Turn?> getTurn(String turnId) async {
    final db = _dbService.database;

    final results = await db.query(
      'turns',
      where: 'id = ?',
      whereArgs: [turnId],
    );

    if (results.isEmpty) {
      return null;
    }

    return Turn.fromMap(results.first);
  }

  @override
  Future<List<Turn>> getTurnsByPlayer(String playerId, {int? limit}) async {
    final db = _dbService.database;

    final results = await db.query(
      'turns',
      where: 'player_id = ?',
      whereArgs: [playerId],
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return results.map((map) => Turn.fromMap(map)).toList();
  }

  @override
  Future<Turn?> getCurrentTurn(String playerId) async {
    final db = _dbService.database;

    final results = await db.query(
      'turns',
      where: 'player_id = ?',
      whereArgs: [playerId],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (results.isEmpty) {
      return null;
    }

    return Turn.fromMap(results.first);
  }

  @override
  Future<Dart> addDart(String turnId, Dart dart) async {
    final db = _dbService.database;

    // Check if turn already has 3 darts
    final darts = await getDartsByTurn(turnId);
    if (darts.length >= 3) {
      throw StateError('Turn already has 3 darts');
    }

    await db.insert('darts', dart.toMap());
    return dart;
  }

  @override
  Future<Dart?> removeLastDart(String turnId) async {
    final db = _dbService.database;

    // Get all darts for this turn
    final darts = await getDartsByTurn(turnId);
    if (darts.isEmpty) {
      return null;
    }

    // Get the last dart (highest dart_number)
    final lastDart = darts.last;

    // Delete it
    await db.delete(
      'darts',
      where: 'id = ?',
      whereArgs: [lastDart.id],
    );

    return lastDart;
  }

  @override
  Future<List<Dart>> getDartsByTurn(String turnId) async {
    final db = _dbService.database;

    final results = await db.query(
      'darts',
      where: 'turn_id = ?',
      whereArgs: [turnId],
      orderBy: 'dart_number ASC',
    );

    return results.map((map) => Dart.fromMap(map)).toList();
  }

  @override
  Future<int> deleteTurn(String turnId) async {
    final db = _dbService.database;

    return await db.delete(
      'turns',
      where: 'id = ?',
      whereArgs: [turnId],
    );
  }
}
