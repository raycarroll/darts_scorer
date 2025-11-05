import 'package:darts_scorer/models/game_type.dart';
import 'package:darts_scorer/models/dart.dart';
import 'package:darts_scorer/models/multiplier.dart';
import 'package:darts_scorer/models/checkout_suggestion.dart';
import 'package:darts_scorer/services/checkout_calculator/checkout_calculator.dart';
import 'game_rule.dart';

class ThreeOhOneRule implements GameRule {
  final CheckoutCalculator _checkoutCalc;

  ThreeOhOneRule(this._checkoutCalc);

  @override
  GameType get gameType => GameType.threeOhOne;

  @override
  int get startingScore => 301;

  @override
  int? calculateScore(int currentScore, Dart dart) {
    final newScore = currentScore - dart.points;

    // Bust if score goes below 0 or equals 1
    if (newScore < 0 || newScore == 1) {
      return null; // Bust
    }

    return newScore;
  }

  @override
  bool isWinningDart(int currentScore, Dart dart) {
    // Must finish on a double
    return currentScore == 0 &&
        (dart.multiplier == Multiplier.double ||
            dart.multiplier == Multiplier.innerBull);
  }

  @override
  bool isBust(int currentScore, Dart dart) {
    final newScore = currentScore - dart.points;

    // Bust conditions:
    // 1. Score goes below 0
    // 2. Score equals 1 (can't finish)
    // 3. Score reaches 0 but not on a double
    if (newScore < 0 || newScore == 1) {
      return true;
    }

    if (newScore == 0) {
      final isDouble = dart.multiplier == Multiplier.double ||
          dart.multiplier == Multiplier.innerBull;
      return !isDouble; // Bust if not finished on double
    }

    return false;
  }

  @override
  bool canFinishFrom(int score, int dartsRemaining) {
    // Maximum possible: T20 + T20 + Bull = 60 + 60 + 50 = 170
    if (score > 170) return false;

    // Check impossible finishes
    const impossibleScores = [169, 168, 166, 165, 163, 162, 159];
    if (impossibleScores.contains(score)) return false;

    return _checkoutCalc.isFinishable(
      score: score,
      dartsAvailable: dartsRemaining,
      mustFinishOnDouble: true,
    );
  }

  @override
  List<CheckoutSuggestion> getCheckoutSuggestions(int score, int dartsRemaining) {
    return _checkoutCalc.findCheckouts(
      score: score,
      dartsAvailable: dartsRemaining,
      mustFinishOnDouble: true,
    );
  }
}
