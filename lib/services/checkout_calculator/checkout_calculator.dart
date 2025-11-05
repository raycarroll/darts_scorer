import 'package:darts_scorer/models/checkout_suggestion.dart';
import 'package:darts_scorer/models/multiplier.dart';
import 'checkout_database.dart';

abstract class CheckoutCalculator {
  List<CheckoutSuggestion> findCheckouts({
    required int score,
    required int dartsAvailable,
    bool mustFinishOnDouble = true,
  });

  bool isFinishable({
    required int score,
    required int dartsAvailable,
    bool mustFinishOnDouble = true,
  });

  CheckoutSuggestion? getBestCheckout({
    required int score,
    required int dartsAvailable,
    bool mustFinishOnDouble = true,
  });

  int getMaxCheckout({
    required int dartsAvailable,
    bool mustFinishOnDouble = true,
  });
}

class CheckoutCalculatorImpl implements CheckoutCalculator {
  final CheckoutDatabase _database = CheckoutDatabase();

  CheckoutCalculatorImpl() {
    _database.initialize();
  }

  @override
  List<CheckoutSuggestion> findCheckouts({
    required int score,
    required int dartsAvailable,
    bool mustFinishOnDouble = true,
  }) {
    // Check if score is valid
    if (score < 2 || score > getMaxCheckout(dartsAvailable: dartsAvailable)) {
      return [];
    }

    // Check impossible finishes
    if (CheckoutDatabase.impossibleFinishes.contains(score)) {
      return [];
    }

    // Try database lookup first
    final checkouts = _database.getCheckouts(score);
    if (checkouts != null) {
      // Filter by darts available
      final filtered = checkouts.where((c) => c.dartsRequired <= dartsAvailable).toList();
      // Sort by difficulty
      filtered.sort((a, b) => a.difficulty.rating.compareTo(b.difficulty.rating));
      return filtered;
    }

    // For scores not in database, compute algorithmically
    return _computeCheckouts(score, dartsAvailable, mustFinishOnDouble);
  }

  @override
  bool isFinishable({
    required int score,
    required int dartsAvailable,
    bool mustFinishOnDouble = true,
  }) {
    if (score < 2 || score > getMaxCheckout(dartsAvailable: dartsAvailable)) {
      return false;
    }

    if (CheckoutDatabase.impossibleFinishes.contains(score)) {
      return false;
    }

    // Check if there are any checkouts
    final checkouts = findCheckouts(
      score: score,
      dartsAvailable: dartsAvailable,
      mustFinishOnDouble: mustFinishOnDouble,
    );

    return checkouts.isNotEmpty;
  }

  @override
  CheckoutSuggestion? getBestCheckout({
    required int score,
    required int dartsAvailable,
    bool mustFinishOnDouble = true,
  }) {
    final checkouts = findCheckouts(
      score: score,
      dartsAvailable: dartsAvailable,
      mustFinishOnDouble: mustFinishOnDouble,
    );

    if (checkouts.isEmpty) {
      return null;
    }

    return checkouts.first; // Already sorted by difficulty
  }

  @override
  int getMaxCheckout({
    required int dartsAvailable,
    bool mustFinishOnDouble = true,
  }) {
    switch (dartsAvailable) {
      case 1:
        return 50; // Bull
      case 2:
        return 110; // T20 + Bull
      case 3:
        return 170; // T20 + T20 + Bull
      default:
        return 0;
    }
  }

  List<CheckoutSuggestion> _computeCheckouts(
    int score,
    int dartsAvailable,
    bool mustFinishOnDouble,
  ) {
    final checkouts = <CheckoutSuggestion>[];

    // Try 1-dart finishes
    if (dartsAvailable >= 1) {
      checkouts.addAll(_findOneDartCheckouts(score, mustFinishOnDouble));
    }

    // Try 2-dart finishes
    if (dartsAvailable >= 2 && checkouts.isEmpty) {
      checkouts.addAll(_findTwoDartCheckouts(score, mustFinishOnDouble));
    }

    // Try 3-dart finishes
    if (dartsAvailable >= 3 && checkouts.isEmpty) {
      checkouts.addAll(_findThreeDartCheckouts(score, mustFinishOnDouble));
    }

    return checkouts;
  }

  List<CheckoutSuggestion> _findOneDartCheckouts(int score, bool mustFinishOnDouble) {
    final checkouts = <CheckoutSuggestion>[];

    // Try doubles (D1-D20)
    for (int zone = 1; zone <= 20; zone++) {
      if (zone * 2 == score) {
        checkouts.add(CheckoutSuggestion(
          score: score,
          darts: [DartSpec(zone, Multiplier.double)],
          description: 'D$zone',
          difficulty: CheckoutDifficulty.easy,
        ));
      }
    }

    // Try bull (50)
    if (score == 50) {
      checkouts.add(CheckoutSuggestion(
        score: 50,
        darts: [DartSpec(25, Multiplier.innerBull)],
        description: 'Bull',
        difficulty: CheckoutDifficulty.easy,
      ));
    }

    return checkouts;
  }

  List<CheckoutSuggestion> _findTwoDartCheckouts(int score, bool mustFinishOnDouble) {
    final checkouts = <CheckoutSuggestion>[];

    // Try combinations with big targets
    final bigTargets = [20, 19, 18, 17, 16];
    for (final target in bigTargets) {
      // Try single, double, triple of target
      for (final mult in [Multiplier.single, Multiplier.double, Multiplier.triple]) {
        final firstPoints = mult == Multiplier.single ? target : (mult == Multiplier.double ? target * 2 : target * 3);
        final remaining = score - firstPoints;

        // Check if remaining can be finished with a double
        if (remaining > 0 && remaining <= 50) {
          final finishDart = _findFinishDart(remaining);
          if (finishDart != null) {
            final firstDart = DartSpec(target, mult);
            checkouts.add(CheckoutSuggestion(
              score: score,
              darts: [firstDart, finishDart],
              description: '${firstDart.notation}-${finishDart.notation}',
              difficulty: CheckoutDifficulty.moderate,
            ));
          }
        }
      }
    }

    return checkouts;
  }

  List<CheckoutSuggestion> _findThreeDartCheckouts(int score, bool mustFinishOnDouble) {
    final checkouts = <CheckoutSuggestion>[];

    // Try T20 + remaining
    final afterT20 = score - 60;
    if (afterT20 > 0 && afterT20 <= 110) {
      final twoDartCheckouts = _findTwoDartCheckouts(afterT20, mustFinishOnDouble);
      for (final twoD in twoDartCheckouts) {
        checkouts.add(CheckoutSuggestion(
          score: score,
          darts: [DartSpec(20, Multiplier.triple), ...twoD.darts],
          description: 'T20-${twoD.description}',
          difficulty: CheckoutDifficulty.hard,
        ));
      }
    }

    return checkouts;
  }

  DartSpec? _findFinishDart(int score) {
    // Check doubles 1-20
    for (int zone = 1; zone <= 20; zone++) {
      if (zone * 2 == score) {
        return DartSpec(zone, Multiplier.double);
      }
    }

    // Check bull
    if (score == 50) {
      return DartSpec(25, Multiplier.innerBull);
    }

    return null;
  }
}
