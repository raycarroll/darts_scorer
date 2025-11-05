import 'package:flutter_test/flutter_test.dart';
import 'package:darts_scorer/models/game_type.dart';
import 'package:darts_scorer/models/multiplier.dart';
import 'package:darts_scorer/services/game_engine/game_engine.dart';
import 'package:darts_scorer/services/persistence/game_repository.dart';
import 'package:darts_scorer/services/persistence/player_repository.dart';
import 'package:darts_scorer/services/persistence/turn_repository.dart';
import 'package:darts_scorer/services/checkout_calculator/checkout_calculator.dart';
import 'package:darts_scorer/services/persistence/database_service.dart';
import '../../test_helpers/test_utils.dart';

void main() {
  late GameEngine gameEngine;
  late DatabaseService databaseService;
  late PlayerRepository playerRepo;

  setUp(() async {
    TestUtils.initializeSqliteForTest();

    databaseService = DatabaseServiceImpl();
    await databaseService.initialize();

    final gameRepo = GameRepositoryImpl(databaseService);
    playerRepo = PlayerRepositoryImpl(databaseService);
    final turnRepo = TurnRepositoryImpl(databaseService);
    final checkoutCalc = CheckoutCalculatorImpl();

    gameEngine = GameEngineImpl(
      gameRepository: gameRepo,
      playerRepository: playerRepo,
      turnRepository: turnRepo,
      checkoutCalculator: checkoutCalc,
    );
  });

  tearDown(() async {
    await databaseService.close();
  });

  group('Finish Detection', () {
    test('checkFinishAvailable returns true for score 170 with 3 darts', () async {
      // Create game
      final game = await gameEngine.createGame(
        gameType: GameType.fiveOhOne,
        playerNames: ['Alice'],
      );

      // Manually set player score to 170
      final players = await playerRepo.getPlayersByGame(game.id);
      await playerRepo.updatePlayerScore(players.first.id, 170);

      // Check finish available
      final finishStatus = await gameEngine.checkFinishAvailable(game.id);

      expect(finishStatus.canFinish, isTrue);
      expect(finishStatus.remainingScore, equals(170));
      expect(finishStatus.suggestions, isNotEmpty);
      expect(finishStatus.suggestions.first.darts.length, lessThanOrEqualTo(3));
    });

    test('checkFinishAvailable returns true for score 50 with 1 dart', () async {
      // Create game
      final game = await gameEngine.createGame(
        gameType: GameType.fiveOhOne,
        playerNames: ['Alice'],
      );

      // Manually set player score to 50
      final players = await playerRepo.getPlayersByGame(game.id);
      await playerRepo.updatePlayerScore(players.first.id, 50);

      // Check finish available
      final finishStatus = await gameEngine.checkFinishAvailable(game.id);

      expect(finishStatus.canFinish, isTrue);
      expect(finishStatus.remainingScore, equals(50));
      expect(finishStatus.suggestions, isNotEmpty);
      // Bull checkout should be available
      expect(finishStatus.suggestions.any((s) => s.darts.first.zone == 25), isTrue);
    });

    test('checkFinishAvailable returns false for score 1', () async {
      // Create game
      final game = await gameEngine.createGame(
        gameType: GameType.fiveOhOne,
        playerNames: ['Alice'],
      );

      // Manually set player score to 1
      final players = await playerRepo.getPlayersByGame(game.id);
      await playerRepo.updatePlayerScore(players.first.id, 1);

      // Check finish available
      final finishStatus = await gameEngine.checkFinishAvailable(game.id);

      expect(finishStatus.canFinish, isFalse);
      expect(finishStatus.remainingScore, equals(1));
      expect(finishStatus.suggestions, isEmpty);
    });

    test('checkFinishAvailable returns false for score 169', () async {
      // Create game
      final game = await gameEngine.createGame(
        gameType: GameType.fiveOhOne,
        playerNames: ['Alice'],
      );

      // Manually set player score to 169 (impossible finish)
      final players = await playerRepo.getPlayersByGame(game.id);
      await playerRepo.updatePlayerScore(players.first.id, 169);

      // Check finish available
      final finishStatus = await gameEngine.checkFinishAvailable(game.id);

      expect(finishStatus.canFinish, isFalse);
      expect(finishStatus.remainingScore, equals(169));
      expect(finishStatus.suggestions, isEmpty);
    });

    test('real-time finish detection updates after each dart', () async {
      // Create game
      final game = await gameEngine.createGame(
        gameType: GameType.fiveOhOne,
        playerNames: ['Alice'],
      );

      // Set player score to 170
      final players = await playerRepo.getPlayersByGame(game.id);
      await playerRepo.updatePlayerScore(players.first.id, 170);

      // Check finish available
      var finishStatus = await gameEngine.checkFinishAvailable(game.id);
      expect(finishStatus.canFinish, isTrue);
      expect(finishStatus.suggestions, isNotEmpty);

      // Record a dart: T20 (60 points) - should leave 110
      await gameEngine.recordDart(
        gameId: game.id,
        zone: 20,
        multiplier: Multiplier.triple,
      );

      // Check finish available again
      finishStatus = await gameEngine.checkFinishAvailable(game.id);
      expect(finishStatus.canFinish, isTrue);
      expect(finishStatus.remainingScore, equals(110));

      // Record another dart: T20 (60 points) - should leave 50
      await gameEngine.recordDart(
        gameId: game.id,
        zone: 20,
        multiplier: Multiplier.triple,
      );

      // Check finish available again
      finishStatus = await gameEngine.checkFinishAvailable(game.id);
      expect(finishStatus.canFinish, isTrue);
      expect(finishStatus.remainingScore, equals(50));
      expect(finishStatus.suggestions.any((s) => s.darts.first.zone == 25), isTrue);
    });

    test('getGameState includes isFinishable flag', () async {
      // Create game
      final game = await gameEngine.createGame(
        gameType: GameType.fiveOhOne,
        playerNames: ['Alice'],
      );

      // Set player score to 50
      final players = await playerRepo.getPlayersByGame(game.id);
      await playerRepo.updatePlayerScore(players.first.id, 50);

      // Get game state
      final gameState = await gameEngine.getGameState(game.id);

      expect(gameState.isFinishable, isTrue);
      expect(gameState.checkouts, isNotEmpty);
    });

    test('getGameState isFinishable is false for impossible finish', () async {
      // Create game
      final game = await gameEngine.createGame(
        gameType: GameType.fiveOhOne,
        playerNames: ['Alice'],
      );

      // Set player score to 169 (impossible)
      final players = await playerRepo.getPlayersByGame(game.id);
      await playerRepo.updatePlayerScore(players.first.id, 169);

      // Get game state
      final gameState = await gameEngine.getGameState(game.id);

      expect(gameState.isFinishable, isFalse);
      expect(gameState.checkouts, isEmpty);
    });
  });
}
