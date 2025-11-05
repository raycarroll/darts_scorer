import 'package:flutter_test/flutter_test.dart';
import 'package:darts_scorer/models/game_type.dart';
import 'package:darts_scorer/models/multiplier.dart';
import 'package:darts_scorer/services/game_engine/game_engine.dart';
import 'package:darts_scorer/services/persistence/game_repository.dart';
import 'package:darts_scorer/services/persistence/player_repository.dart';
import 'package:darts_scorer/services/persistence/turn_repository.dart';
import 'package:darts_scorer/services/checkout_calculator/checkout_calculator.dart';
import 'package:darts_scorer/services/persistence/database_service.dart';
import '../test_helpers/test_utils.dart';

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

  group('US2: Finish Detection & Checkout Integration Tests', () {
    test('score 170 shows finish available with checkouts', () async {
      // Arrange
      final game = await gameEngine.createGame(
        gameType: GameType.fiveOhOne,
        playerNames: ['Alice'],
      );

      final players = await playerRepo.getPlayersByGame(game.id);
      await playerRepo.updatePlayerScore(players.first.id, 170);

      // Act
      final state = await gameEngine.getGameState(game.id);

      // Assert
      expect(state.isFinishable, isTrue);
      expect(state.checkouts, isNotEmpty);
      expect(state.checkouts.first.score, equals(170));
    });

    test('score 50 shows multiple checkout options', () async {
      // Arrange
      final game = await gameEngine.createGame(
        gameType: GameType.fiveOhOne,
        playerNames: ['Alice'],
      );

      final players = await playerRepo.getPlayersByGame(game.id);
      await playerRepo.updatePlayerScore(players.first.id, 50);

      // Act
      final state = await gameEngine.getGameState(game.id);

      // Assert
      expect(state.isFinishable, isTrue);
      expect(state.checkouts, isNotEmpty);
      // Should include Bull (50) and D25 options
      expect(state.checkouts.any((c) => c.darts.first.zone == 25), isTrue);
    });

    test('score 1 shows no finish available', () async {
      // Arrange
      final game = await gameEngine.createGame(
        gameType: GameType.fiveOhOne,
        playerNames: ['Alice'],
      );

      final players = await playerRepo.getPlayersByGame(game.id);
      await playerRepo.updatePlayerScore(players.first.id, 1);

      // Act
      final state = await gameEngine.getGameState(game.id);

      // Assert
      expect(state.isFinishable, isFalse);
      expect(state.checkouts, isEmpty);
    });

    test('score 60, hit T20 results in bust', () async {
      // Arrange
      final game = await gameEngine.createGame(
        gameType: GameType.fiveOhOne,
        playerNames: ['Alice'],
      );

      final players = await playerRepo.getPlayersByGame(game.id);
      await playerRepo.updatePlayerScore(players.first.id, 60);

      // Act - hit T20 (60 points, would result in 0 but not on double)
      await gameEngine.recordDart(
        gameId: game.id,
        zone: 20,
        multiplier: Multiplier.triple,
      );

      final state = await gameEngine.getGameState(game.id);

      // Assert - score should not have changed (bust)
      expect(state.currentPlayer.currentScore, equals(60));
    });

    test('score 40, hit D20 results in win', () async {
      // Arrange
      final game = await gameEngine.createGame(
        gameType: GameType.fiveOhOne,
        playerNames: ['Alice'],
      );

      final players = await playerRepo.getPlayersByGame(game.id);
      await playerRepo.updatePlayerScore(players.first.id, 40);

      // Act - hit D20 (40 points, finishes on double)
      await gameEngine.recordDart(
        gameId: game.id,
        zone: 20,
        multiplier: Multiplier.double,
      );

      final state = await gameEngine.getGameState(game.id);

      // Assert - should have won
      expect(state.currentPlayer.currentScore, equals(0));
      expect(state.game.winnerId, equals(players.first.id));
    });
  });
}
