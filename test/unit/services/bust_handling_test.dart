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

  group('Bust Handling', () {
    test('score goes below 0 is bust and reverts', () async {
      // Create game
      final game = await gameEngine.createGame(
        gameType: GameType.fiveOhOne,
        playerNames: ['Alice'],
      );

      // Set player score to 20
      final players = await playerRepo.getPlayersByGame(game.id);
      await playerRepo.updatePlayerScore(players.first.id, 20);

      // Record dart that would bring score below 0: T20 (60 points)
      await gameEngine.recordDart(
        gameId: game.id,
        zone: 20,
        multiplier: Multiplier.triple,
      );

      // Check score didn't change (bust)
      final state = await gameEngine.getGameState(game.id);
      expect(state.currentPlayer.currentScore, equals(20));
    });

    test('score equals 1 is bust and reverts', () async {
      // Create game
      final game = await gameEngine.createGame(
        gameType: GameType.fiveOhOne,
        playerNames: ['Alice'],
      );

      // Set player score to 3
      final players = await playerRepo.getPlayersByGame(game.id);
      await playerRepo.updatePlayerScore(players.first.id, 3);

      // Record dart that would leave score at 1: single 2
      await gameEngine.recordDart(
        gameId: game.id,
        zone: 2,
        multiplier: Multiplier.single,
      );

      // Check score didn't change (bust)
      final state = await gameEngine.getGameState(game.id);
      expect(state.currentPlayer.currentScore, equals(3));
    });

    test('finish on non-double is bust', () async {
      // Create game
      final game = await gameEngine.createGame(
        gameType: GameType.fiveOhOne,
        playerNames: ['Alice'],
      );

      // Set player score to 20
      final players = await playerRepo.getPlayersByGame(game.id);
      await playerRepo.updatePlayerScore(players.first.id, 20);

      // Record dart that would finish but not on double: single 20
      await gameEngine.recordDart(
        gameId: game.id,
        zone: 20,
        multiplier: Multiplier.single,
      );

      // Check score didn't change (bust) and game not completed
      final state = await gameEngine.getGameState(game.id);
      expect(state.currentPlayer.currentScore, equals(20));
      expect(state.game.winnerId, isNull);
    });

    test('finish on double with exact 0 is win', () async {
      // Create game
      final game = await gameEngine.createGame(
        gameType: GameType.fiveOhOne,
        playerNames: ['Alice'],
      );

      // Set player score to 20
      final players = await playerRepo.getPlayersByGame(game.id);
      await playerRepo.updatePlayerScore(players.first.id, 20);

      // Record dart that finishes on double: D10
      await gameEngine.recordDart(
        gameId: game.id,
        zone: 10,
        multiplier: Multiplier.double,
      );

      // Check score is 0 and game completed
      final state = await gameEngine.getGameState(game.id);
      expect(state.currentPlayer.currentScore, equals(0));
      expect(state.game.winnerId, equals(players.first.id));
    });

    test('complete turn throws error when turn is bust', () async {
      // Create game
      final game = await gameEngine.createGame(
        gameType: GameType.fiveOhOne,
        playerNames: ['Alice'],
      );

      // Set player score to 20
      final players = await playerRepo.getPlayersByGame(game.id);
      await playerRepo.updatePlayerScore(players.first.id, 20);

      // Record bust dart
      await gameEngine.recordDart(
        gameId: game.id,
        zone: 20,
        multiplier: Multiplier.triple,
      );

      // Try to complete turn - should throw error
      expect(
        () => gameEngine.completeTurn(game.id),
        throwsStateError,
      );
    });
  });
}
