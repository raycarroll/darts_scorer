import 'package:darts_scorer/models/player.dart';
import 'package:darts_scorer/models/turn.dart';
import 'package:darts_scorer/models/dart.dart';

class PlayerStatistics {
  final String playerId;
  final int totalDartsThrown;
  final double averagePerDart;
  final double averagePerTurn;
  final int highestTurnScore;
  final double checkoutPercentage;
  final int totalScore;

  PlayerStatistics({
    required this.playerId,
    required this.totalDartsThrown,
    required this.averagePerDart,
    required this.averagePerTurn,
    required this.highestTurnScore,
    required this.checkoutPercentage,
    required this.totalScore,
  });
}

class StatsCalculator {
  static PlayerStatistics calculatePlayerStats({
    required Player player,
    required List<Turn> turns,
    required Map<String, List<Dart>> dartsByTurn,
    required int startingScore,
  }) {
    int totalDarts = 0;
    int totalPoints = 0;
    int highestTurn = 0;
    int checkoutAttempts = 0;
    int successfulCheckouts = 0;

    for (final turn in turns) {
      final darts = dartsByTurn[turn.id] ?? [];
      totalDarts += darts.length;

      int turnScore = 0;
      for (final dart in darts) {
        turnScore += dart.points;
      }

      totalPoints += turnScore;
      if (turnScore > highestTurn) {
        highestTurn = turnScore;
      }

      // Simplified checkout tracking (would need more context in real implementation)
      // For now, just track if turn ended in a finish attempt
    }

    final averagePerDart = totalDarts > 0 ? totalPoints / totalDarts : 0.0;
    final averagePerTurn = turns.isNotEmpty ? totalPoints / turns.length : 0.0;
    final checkoutPct = checkoutAttempts > 0
        ? (successfulCheckouts / checkoutAttempts) * 100
        : 0.0;

    final totalScore = startingScore - player.currentScore;

    return PlayerStatistics(
      playerId: player.id,
      totalDartsThrown: totalDarts,
      averagePerDart: averagePerDart,
      averagePerTurn: averagePerTurn,
      highestTurnScore: highestTurn,
      checkoutPercentage: checkoutPct,
      totalScore: totalScore,
    );
  }

  static Map<String, PlayerStatistics> calculateAllPlayerStats({
    required List<Player> players,
    required Map<String, List<Turn>> turnsByPlayer,
    required Map<String, List<Dart>> dartsByTurn,
    required int startingScore,
  }) {
    final stats = <String, PlayerStatistics>{};

    for (final player in players) {
      final playerTurns = turnsByPlayer[player.id] ?? [];
      stats[player.id] = calculatePlayerStats(
        player: player,
        turns: playerTurns,
        dartsByTurn: dartsByTurn,
        startingScore: startingScore,
      );
    }

    return stats;
  }
}
