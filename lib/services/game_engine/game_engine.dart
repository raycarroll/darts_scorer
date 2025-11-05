import 'package:uuid/uuid.dart';
import 'package:darts_scorer/models/game.dart';
import 'package:darts_scorer/models/game_type.dart';
import 'package:darts_scorer/models/game_status.dart';
import 'package:darts_scorer/models/player.dart';
import 'package:darts_scorer/models/turn.dart';
import 'package:darts_scorer/models/dart.dart';
import 'package:darts_scorer/models/multiplier.dart';
import 'package:darts_scorer/models/checkout_suggestion.dart';
import 'package:darts_scorer/services/persistence/game_repository.dart';
import 'package:darts_scorer/services/persistence/player_repository.dart';
import 'package:darts_scorer/services/persistence/turn_repository.dart';
import 'package:darts_scorer/services/checkout_calculator/checkout_calculator.dart';
import 'rules/game_rule.dart';
import 'rules/five_oh_one_rule.dart';
import 'rules/three_oh_one_rule.dart';
import 'rules/cricket_rule.dart';
import 'rules/around_clock_rule.dart';

class GameState {
  final Game game;
  final List<Player> players;
  final Player currentPlayer;
  final Turn? currentTurn;
  final int currentRound;
  final bool isFinishable;
  final List<CheckoutSuggestion> checkouts;
  final List<Dart> currentTurnDarts;

  GameState({
    required this.game,
    required this.players,
    required this.currentPlayer,
    this.currentTurn,
    required this.currentRound,
    required this.isFinishable,
    this.checkouts = const [],
    this.currentTurnDarts = const [],
  });
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult.valid()
      : isValid = true,
        errorMessage = null;

  ValidationResult.invalid(this.errorMessage) : isValid = false;
}

class FinishStatus {
  final bool canFinish;
  final int remainingScore;
  final List<CheckoutSuggestion> suggestions;

  FinishStatus({
    required this.canFinish,
    required this.remainingScore,
    this.suggestions = const [],
  });
}

abstract class GameEngine {
  Future<Game> createGame({
    required GameType gameType,
    required List<String> playerNames,
  });

  Future<GameState> recordDart({
    required String gameId,
    required int zone,
    required Multiplier multiplier,
  });

  Future<GameState> undoLastDart(String gameId);
  Future<GameState> completeTurn(String gameId);
  Future<ValidationResult> validateDart({
    required String gameId,
    required int zone,
    required Multiplier multiplier,
  });
  Future<FinishStatus> checkFinishAvailable(String gameId);
  Future<GameState> getGameState(String gameId);
  Future<GameState> abandonGame(String gameId);
}

class GameEngineImpl implements GameEngine {
  final GameRepository _gameRepo;
  final PlayerRepository _playerRepo;
  final TurnRepository _turnRepo;
  final CheckoutCalculator _checkoutCalc;
  final Uuid _uuid = const Uuid();

  GameEngineImpl({
    required GameRepository gameRepository,
    required PlayerRepository playerRepository,
    required TurnRepository turnRepository,
    required CheckoutCalculator checkoutCalculator,
  })  : _gameRepo = gameRepository,
        _playerRepo = playerRepository,
        _turnRepo = turnRepository,
        _checkoutCalc = checkoutCalculator;

  GameRule _getRuleForGameType(GameType gameType) {
    switch (gameType) {
      case GameType.fiveOhOne:
        return FiveOhOneRule(_checkoutCalc);
      case GameType.threeOhOne:
        return ThreeOhOneRule(_checkoutCalc);
      case GameType.cricket:
        return CricketRule();
      case GameType.aroundClock:
        return AroundClockRule();
    }
  }

  @override
  Future<Game> createGame({
    required GameType gameType,
    required List<String> playerNames,
  }) async {
    if (playerNames.isEmpty || playerNames.length > 4) {
      throw ArgumentError('Must have 1-4 players');
    }

    final uniqueNames = playerNames.toSet();
    if (uniqueNames.length != playerNames.length) {
      throw ArgumentError('Player names must be unique');
    }

    final rule = _getRuleForGameType(gameType);

    final game = Game(
      id: _uuid.v4(),
      gameType: gameType,
      startingScore: rule.startingScore,
      status: GameStatus.active,
      createdAt: DateTime.now(),
    );

    final players = playerNames.asMap().entries.map((entry) {
      return Player(
        id: _uuid.v4(),
        gameId: game.id,
        name: entry.value,
        orderPosition: entry.key,
        currentScore: rule.startingScore,
        isActive: true,
      );
    }).toList();

    await _gameRepo.createGame(game, players);

    // Create first turn for first player
    final firstTurn = Turn(
      id: _uuid.v4(),
      playerId: players.first.id,
      roundNumber: 1,
      turnNumber: 1,
      createdAt: DateTime.now(),
    );
    await _turnRepo.createTurn(firstTurn);

    return game;
  }

  @override
  Future<GameState> recordDart({
    required String gameId,
    required int zone,
    required Multiplier multiplier,
  }) async {
    final game = await _gameRepo.getGame(gameId);
    if (game == null) {
      throw ArgumentError('Game not found');
    }

    if (game.status != GameStatus.active) {
      throw StateError('Game is not active');
    }

    // Validate dart
    final validation = await validateDart(gameId: gameId, zone: zone, multiplier: multiplier);
    if (!validation.isValid) {
      throw ArgumentError(validation.errorMessage);
    }

    final players = await _playerRepo.getPlayersByGame(gameId);
    final currentPlayer = await _getCurrentActivePlayer(gameId);
    final currentTurn = await _turnRepo.getCurrentTurn(currentPlayer.id);

    if (currentTurn == null) {
      throw StateError('No current turn');
    }

    final existingDarts = await _turnRepo.getDartsByTurn(currentTurn.id);
    if (existingDarts.length >= 3) {
      throw StateError('Turn already has 3 darts');
    }

    // Calculate points
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

    final dart = Dart(
      id: _uuid.v4(),
      turnId: currentTurn.id,
      dartNumber: existingDarts.length + 1,
      zone: zone,
      multiplier: multiplier,
      points: points,
    );

    await _turnRepo.addDart(currentTurn.id, dart);

    // Update player score
    final rule = _getRuleForGameType(game.gameType);
    final newScore = rule.calculateScore(currentPlayer.currentScore, dart);

    if (newScore != null) {
      // Valid throw
      await _playerRepo.updatePlayerScore(currentPlayer.id, newScore);

      // Check if won
      if (newScore == 0 && rule.isWinningDart(newScore, dart)) {
        // Player won!
        final updatedGame = game.copyWith(
          status: GameStatus.completed,
          completedAt: DateTime.now(),
          winnerId: currentPlayer.id,
        );
        await _gameRepo.updateGame(updatedGame);
      }
    }
    // If newScore is null, it's a bust - don't update score

    return await getGameState(gameId);
  }

  @override
  Future<GameState> undoLastDart(String gameId) async {
    final game = await _gameRepo.getGame(gameId);
    if (game == null) {
      throw ArgumentError('Game not found');
    }

    if (game.status != GameStatus.active) {
      throw StateError('Game is not active');
    }

    final currentPlayer = await _getCurrentActivePlayer(gameId);
    final currentTurn = await _turnRepo.getCurrentTurn(currentPlayer.id);

    if (currentTurn == null) {
      throw StateError('No current turn');
    }

    final darts = await _turnRepo.getDartsByTurn(currentTurn.id);
    if (darts.isEmpty) {
      throw StateError('No darts to undo');
    }

    final lastDart = darts.last;

    // Revert score
    final rule = _getRuleForGameType(game.gameType);
    final revertedScore = currentPlayer.currentScore + lastDart.points;
    await _playerRepo.updatePlayerScore(currentPlayer.id, revertedScore);

    // Remove dart
    await _turnRepo.removeLastDart(currentTurn.id);

    return await getGameState(gameId);
  }

  @override
  Future<GameState> completeTurn(String gameId) async {
    final game = await _gameRepo.getGame(gameId);
    if (game == null) {
      throw ArgumentError('Game not found');
    }

    if (game.status != GameStatus.active) {
      throw StateError('Game is not active');
    }

    final players = await _playerRepo.getPlayersByGame(gameId);
    final currentPlayer = await _getCurrentActivePlayer(gameId);
    final currentTurn = await _turnRepo.getCurrentTurn(currentPlayer.id);

    if (currentTurn == null) {
      throw StateError('No current turn');
    }

    // Check for bust
    final darts = await _turnRepo.getDartsByTurn(currentTurn.id);
    final rule = _getRuleForGameType(game.gameType);

    for (final dart in darts) {
      if (rule.isBust(currentPlayer.currentScore + dart.points, dart)) {
        throw StateError('Cannot complete turn - turn is bust. Please undo.');
      }
    }

    // Find next player
    final currentIndex = players.indexWhere((p) => p.id == currentPlayer.id);
    final nextIndex = (currentIndex + 1) % players.length;
    final nextPlayer = players[nextIndex];

    // Increment round if we're back to first player
    final nextRound = nextIndex == 0 ? currentTurn.roundNumber + 1 : currentTurn.roundNumber;

    // Get next player's last turn number
    final nextPlayerTurns = await _turnRepo.getTurnsByPlayer(nextPlayer.id);
    final nextTurnNumber = nextPlayerTurns.isEmpty ? 1 : nextPlayerTurns.first.turnNumber + 1;

    // Create new turn for next player
    final newTurn = Turn(
      id: _uuid.v4(),
      playerId: nextPlayer.id,
      roundNumber: nextRound,
      turnNumber: nextTurnNumber,
      createdAt: DateTime.now(),
    );
    await _turnRepo.createTurn(newTurn);

    return await getGameState(gameId);
  }

  @override
  Future<ValidationResult> validateDart({
    required String gameId,
    required int zone,
    required Multiplier multiplier,
  }) async {
    // Validate zone
    if (zone < 0 || (zone > 20 && zone != 25)) {
      return ValidationResult.invalid('Invalid zone: must be 0, 1-20, or 25');
    }

    // Validate multiplier for zone
    if (zone == 25) {
      if (multiplier != Multiplier.outerBull && multiplier != Multiplier.innerBull) {
        return ValidationResult.invalid('Invalid multiplier for bull');
      }
    } else if (zone == 0) {
      if (multiplier != Multiplier.single) {
        return ValidationResult.invalid('Miss must be single multiplier');
      }
    }

    return ValidationResult.valid();
  }

  @override
  Future<FinishStatus> checkFinishAvailable(String gameId) async {
    final currentPlayer = await _getCurrentActivePlayer(gameId);
    final game = await _gameRepo.getGame(gameId);

    if (game == null) {
      throw ArgumentError('Game not found');
    }

    final rule = _getRuleForGameType(game.gameType);
    final currentTurn = await _turnRepo.getCurrentTurn(currentPlayer.id);

    if (currentTurn == null) {
      return FinishStatus(canFinish: false, remainingScore: currentPlayer.currentScore);
    }

    final darts = await _turnRepo.getDartsByTurn(currentTurn.id);
    final dartsRemaining = 3 - darts.length;

    final canFinish = rule.canFinishFrom(currentPlayer.currentScore, dartsRemaining);
    final suggestions = canFinish
        ? rule.getCheckoutSuggestions(currentPlayer.currentScore, dartsRemaining)
        : <CheckoutSuggestion>[];

    return FinishStatus(
      canFinish: canFinish,
      remainingScore: currentPlayer.currentScore,
      suggestions: suggestions,
    );
  }

  @override
  Future<GameState> getGameState(String gameId) async {
    final game = await _gameRepo.getGame(gameId);
    if (game == null) {
      throw ArgumentError('Game not found');
    }

    final players = await _playerRepo.getPlayersByGame(gameId);
    final currentPlayer = await _getCurrentActivePlayer(gameId);
    final currentTurn = await _turnRepo.getCurrentTurn(currentPlayer.id);

    final currentTurnDarts = currentTurn != null
        ? await _turnRepo.getDartsByTurn(currentTurn.id)
        : <Dart>[];

    final finishStatus = await checkFinishAvailable(gameId);

    return GameState(
      game: game,
      players: players,
      currentPlayer: currentPlayer,
      currentTurn: currentTurn,
      currentRound: currentTurn?.roundNumber ?? 1,
      isFinishable: finishStatus.canFinish,
      checkouts: finishStatus.suggestions,
      currentTurnDarts: currentTurnDarts,
    );
  }

  @override
  Future<GameState> abandonGame(String gameId) async {
    final game = await _gameRepo.getGame(gameId);
    if (game == null) {
      throw ArgumentError('Game not found');
    }

    if (game.status == GameStatus.completed) {
      throw StateError('Cannot abandon completed game');
    }

    final updatedGame = game.copyWith(
      status: GameStatus.abandoned,
      completedAt: DateTime.now(),
    );

    await _gameRepo.updateGame(updatedGame);

    return await getGameState(gameId);
  }

  Future<Player> _getCurrentActivePlayer(String gameId) async {
    final players = await _playerRepo.getPlayersByGame(gameId);

    // Find who has the most recent turn
    Turn? mostRecentTurn;
    Player? playerWithMostRecentTurn;

    for (final player in players) {
      final turns = await _turnRepo.getTurnsByPlayer(player.id, limit: 1);
      if (turns.isNotEmpty) {
        if (mostRecentTurn == null ||
            turns.first.createdAt.isAfter(mostRecentTurn.createdAt)) {
          mostRecentTurn = turns.first;
          playerWithMostRecentTurn = player;
        }
      }
    }

    return playerWithMostRecentTurn ?? players.first;
  }
}
