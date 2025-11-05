import 'package:darts_scorer/models/game.dart';
import 'package:darts_scorer/models/game_type.dart';
import 'package:darts_scorer/models/game_status.dart';
import 'package:darts_scorer/models/player.dart';
import 'package:darts_scorer/models/turn.dart';
import 'package:darts_scorer/models/dart.dart';
import 'package:darts_scorer/models/multiplier.dart';

class MockData {
  // Sample game IDs
  static const String gameId1 = 'game-001';
  static const String gameId2 = 'game-002';

  // Sample player IDs
  static const String player1Id = 'player-001';
  static const String player2Id = 'player-002';
  static const String player3Id = 'player-003';

  // Sample turn IDs
  static const String turn1Id = 'turn-001';
  static const String turn2Id = 'turn-002';

  // Sample dart IDs
  static const String dart1Id = 'dart-001';
  static const String dart2Id = 'dart-002';
  static const String dart3Id = 'dart-003';

  // Create sample 501 game
  static Game createGame501({
    String? id,
    GameStatus status = GameStatus.active,
    String? winnerId,
  }) {
    return Game(
      id: id ?? gameId1,
      gameType: GameType.fiveOhOne,
      startingScore: 501,
      status: status,
      createdAt: DateTime(2025, 10, 23, 10, 0, 0),
      completedAt: status == GameStatus.completed
          ? DateTime(2025, 10, 23, 11, 0, 0)
          : null,
      winnerId: winnerId,
    );
  }

  // Create sample player
  static Player createPlayer({
    String? id,
    String? gameId,
    String name = 'Alice',
    int orderPosition = 0,
    int currentScore = 501,
    bool isActive = true,
  }) {
    return Player(
      id: id ?? player1Id,
      gameId: gameId ?? gameId1,
      name: name,
      orderPosition: orderPosition,
      currentScore: currentScore,
      isActive: isActive,
    );
  }

  // Create sample turn
  static Turn createTurn({
    String? id,
    String? playerId,
    int roundNumber = 1,
    int turnNumber = 1,
  }) {
    return Turn(
      id: id ?? turn1Id,
      playerId: playerId ?? player1Id,
      roundNumber: roundNumber,
      turnNumber: turnNumber,
      createdAt: DateTime(2025, 10, 23, 10, 5, 0),
    );
  }

  // Create sample dart
  static Dart createDart({
    String? id,
    String? turnId,
    int dartNumber = 1,
    int zone = 20,
    Multiplier multiplier = Multiplier.triple,
  }) {
    int points;
    switch (multiplier) {
      case Multiplier.single:
        points = zone;
        break;
      case Multiplier.double:
        points = zone * 2;
        break;
      case Multiplier.triple:
        points = zone * 3;
        break;
      case Multiplier.outerBull:
        points = 25;
        break;
      case Multiplier.innerBull:
        points = 50;
        break;
    }

    return Dart(
      id: id ?? dart1Id,
      turnId: turnId ?? turn1Id,
      dartNumber: dartNumber,
      zone: zone,
      multiplier: multiplier,
      points: points,
    );
  }

  // Create multiple players for multi-player game
  static List<Player> createPlayers(String gameId, int count) {
    final names = ['Alice', 'Bob', 'Charlie', 'Diana'];
    return List.generate(
      count,
      (i) => createPlayer(
        id: 'player-00${i + 1}',
        gameId: gameId,
        name: names[i],
        orderPosition: i,
      ),
    );
  }
}
