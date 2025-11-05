import 'package:flutter_test/flutter_test.dart';
import 'package:darts_scorer/models/game.dart';
import 'package:darts_scorer/models/game_type.dart';
import 'package:darts_scorer/models/game_status.dart';
import 'package:darts_scorer/models/player.dart';
import 'package:darts_scorer/models/turn.dart';
import 'package:darts_scorer/models/dart.dart';
import 'package:darts_scorer/models/multiplier.dart';
import 'package:darts_scorer/services/persistence/database_service.dart';
import 'package:darts_scorer/services/persistence/game_repository.dart';
import 'package:darts_scorer/services/persistence/player_repository.dart';
import 'package:darts_scorer/services/persistence/turn_repository.dart';
import '../test_helpers/test_utils.dart';
import '../test_helpers/mock_data.dart';

void main() {
  late DatabaseService dbService;
  late GameRepository gameRepo;
  late PlayerRepository playerRepo;
  late TurnRepository turnRepo;

  setUpAll(() {
    TestUtils.initializeSqliteForTest();
  });

  setUp(() async {
    dbService = DatabaseServiceImpl();
    await dbService.initialize();
    gameRepo = GameRepositoryImpl(dbService);
    playerRepo = PlayerRepositoryImpl(dbService);
    turnRepo = TurnRepositoryImpl(dbService);
  });

  tearDown(() async {
    await dbService.deleteAll();
    await dbService.close();
  });

  group('DatabaseService', () {
    test('initialize creates database', () async {
      expect(dbService.database, isNotNull);
      expect(dbService.version, equals(1));
    });

    test('foreign keys are enabled', () async {
      final result = await dbService.database.rawQuery('PRAGMA foreign_keys');
      expect(result.first['foreign_keys'], equals(1));
    });
  });

  group('GameRepository', () {
    test('createGame with players saves to database', () async {
      final game = MockData.createGame501();
      final players = MockData.createPlayers(game.id, 2);

      final result = await gameRepo.createGame(game, players);

      expect(result.id, equals(game.id));
      final retrieved = await gameRepo.getGame(game.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.gameType, equals(GameType.fiveOhOne));
    });

    test('getGame returns null for non-existent game', () async {
      final result = await gameRepo.getGame('non-existent');
      expect(result, isNull);
    });

    test('updateGame modifies existing game', () async {
      final game = MockData.createGame501();
      await gameRepo.createGame(game, []);

      final updated = game.copyWith(status: GameStatus.completed);
      await gameRepo.updateGame(updated);

      final retrieved = await gameRepo.getGame(game.id);
      expect(retrieved!.status, equals(GameStatus.completed));
    });

    test('deleteGame removes game and cascades to players', () async {
      final game = MockData.createGame501();
      final players = MockData.createPlayers(game.id, 2);
      await gameRepo.createGame(game, players);

      await gameRepo.deleteGame(game.id);

      final retrieved = await gameRepo.getGame(game.id);
      expect(retrieved, isNull);

      final retrievedPlayers = await playerRepo.getPlayersByGame(game.id);
      expect(retrievedPlayers, isEmpty);
    });

    test('getActiveGame returns active game', () async {
      final game = MockData.createGame501(status: GameStatus.active);
      await gameRepo.createGame(game, []);

      final active = await gameRepo.getActiveGame();
      expect(active, isNotNull);
      expect(active!.id, equals(game.id));
    });

    test('getGames filters by status', () async {
      final game1 = MockData.createGame501(
        id: 'game-1',
        status: GameStatus.active,
      );
      final game2 = MockData.createGame501(
        id: 'game-2',
        status: GameStatus.completed,
      );
      await gameRepo.createGame(game1, []);
      await gameRepo.createGame(game2, []);

      final activeGames = await gameRepo.getGames(status: GameStatus.active);
      expect(activeGames.length, equals(1));
      expect(activeGames.first.id, equals('game-1'));
    });
  });

  group('PlayerRepository', () {
    test('createPlayer saves to database', () async {
      final game = MockData.createGame501();
      await gameRepo.createGame(game, []);

      final player = MockData.createPlayer(gameId: game.id);
      final result = await playerRepo.createPlayer(player);

      expect(result.id, equals(player.id));
    });

    test('getPlayersByGame returns players in order', () async {
      final game = MockData.createGame501();
      final players = MockData.createPlayers(game.id, 3);
      await gameRepo.createGame(game, players);

      final retrieved = await playerRepo.getPlayersByGame(game.id);
      expect(retrieved.length, equals(3));
      expect(retrieved[0].orderPosition, equals(0));
      expect(retrieved[1].orderPosition, equals(1));
      expect(retrieved[2].orderPosition, equals(2));
    });

    test('updatePlayerScore modifies score', () async {
      final game = MockData.createGame501();
      final player = MockData.createPlayer(gameId: game.id, currentScore: 501);
      await gameRepo.createGame(game, [player]);

      await playerRepo.updatePlayerScore(player.id, 441);

      final retrieved = await playerRepo.getPlayer(player.id);
      expect(retrieved!.currentScore, equals(441));
    });
  });

  group('TurnRepository', () {
    test('createTurn saves to database', () async {
      final game = MockData.createGame501();
      final player = MockData.createPlayer(gameId: game.id);
      await gameRepo.createGame(game, [player]);

      final turn = MockData.createTurn(playerId: player.id);
      final result = await turnRepo.createTurn(turn);

      expect(result.id, equals(turn.id));
    });

    test('addDart saves dart to turn', () async {
      final game = MockData.createGame501();
      final player = MockData.createPlayer(gameId: game.id);
      await gameRepo.createGame(game, [player]);

      final turn = MockData.createTurn(playerId: player.id);
      await turnRepo.createTurn(turn);

      final dart = MockData.createDart(turnId: turn.id);
      final result = await turnRepo.addDart(turn.id, dart);

      expect(result.id, equals(dart.id));
      expect(result.points, equals(60)); // T20
    });

    test('addDart throws on 4th dart', () async {
      final game = MockData.createGame501();
      final player = MockData.createPlayer(gameId: game.id);
      await gameRepo.createGame(game, [player]);

      final turn = MockData.createTurn(playerId: player.id);
      await turnRepo.createTurn(turn);

      // Add 3 darts
      await turnRepo.addDart(turn.id, MockData.createDart(turnId: turn.id, id: 'dart-1', dartNumber: 1));
      await turnRepo.addDart(turn.id, MockData.createDart(turnId: turn.id, id: 'dart-2', dartNumber: 2));
      await turnRepo.addDart(turn.id, MockData.createDart(turnId: turn.id, id: 'dart-3', dartNumber: 3));

      // 4th dart should throw
      expect(
        () => turnRepo.addDart(turn.id, MockData.createDart(turnId: turn.id, id: 'dart-4', dartNumber: 4)),
        throwsStateError,
      );
    });

    test('removeLastDart removes most recent dart', () async {
      final game = MockData.createGame501();
      final player = MockData.createPlayer(gameId: game.id);
      await gameRepo.createGame(game, [player]);

      final turn = MockData.createTurn(playerId: player.id);
      await turnRepo.createTurn(turn);

      final dart1 = MockData.createDart(turnId: turn.id, id: 'dart-1', dartNumber: 1);
      final dart2 = MockData.createDart(turnId: turn.id, id: 'dart-2', dartNumber: 2);
      await turnRepo.addDart(turn.id, dart1);
      await turnRepo.addDart(turn.id, dart2);

      final removed = await turnRepo.removeLastDart(turn.id);
      expect(removed, isNotNull);
      expect(removed!.id, equals('dart-2'));

      final darts = await turnRepo.getDartsByTurn(turn.id);
      expect(darts.length, equals(1));
    });

    test('getCurrentTurn returns most recent turn', () async {
      final game = MockData.createGame501();
      final player = MockData.createPlayer(gameId: game.id);
      await gameRepo.createGame(game, [player]);

      final turn1 = MockData.createTurn(playerId: player.id, id: 'turn-1', turnNumber: 1);
      final turn2 = MockData.createTurn(playerId: player.id, id: 'turn-2', turnNumber: 2);
      await turnRepo.createTurn(turn1);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await turnRepo.createTurn(turn2);

      final current = await turnRepo.getCurrentTurn(player.id);
      expect(current, isNotNull);
      expect(current!.id, equals('turn-2'));
    });
  });

  group('Transaction atomicity', () {
    test('createGame is atomic', () async {
      final game = MockData.createGame501();
      final players = MockData.createPlayers(game.id, 2);

      await gameRepo.createGame(game, players);

      final retrievedPlayers = await playerRepo.getPlayersByGame(game.id);
      expect(retrievedPlayers.length, equals(2));
    });
  });

  group('Foreign key constraints', () {
    test('cannot create player with invalid game_id', () async {
      final player = MockData.createPlayer(gameId: 'non-existent');

      expect(
        () => playerRepo.createPlayer(player),
        throwsException,
      );
    });

    test('cannot create turn with invalid player_id', () async {
      final turn = MockData.createTurn(playerId: 'non-existent');

      expect(
        () => turnRepo.createTurn(turn),
        throwsException,
      );
    });
  });
}
