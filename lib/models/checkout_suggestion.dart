import 'multiplier.dart';

enum CheckoutDifficulty {
  easy,
  moderate,
  challenging,
  hard,
  expert,
}

extension CheckoutDifficultyExtension on CheckoutDifficulty {
  int get rating {
    switch (this) {
      case CheckoutDifficulty.easy:
        return 1;
      case CheckoutDifficulty.moderate:
        return 2;
      case CheckoutDifficulty.challenging:
        return 3;
      case CheckoutDifficulty.hard:
        return 4;
      case CheckoutDifficulty.expert:
        return 5;
    }
  }
}

class DartSpec {
  final int zone;
  final Multiplier multiplier;

  DartSpec(this.zone, this.multiplier);

  int get points {
    switch (multiplier) {
      case Multiplier.single:
        return zone;
      case Multiplier.double:
        return zone * 2;
      case Multiplier.triple:
        return zone * 3;
      case Multiplier.outerBull:
        return 25;
      case Multiplier.innerBull:
        return 50;
    }
  }

  String get notation {
    switch (multiplier) {
      case Multiplier.single:
        return '$zone';
      case Multiplier.double:
        return 'D$zone';
      case Multiplier.triple:
        return 'T$zone';
      case Multiplier.outerBull:
        return '25';
      case Multiplier.innerBull:
        return 'Bull';
    }
  }

  @override
  String toString() => notation;
}

class CheckoutSuggestion {
  final int score;
  final List<DartSpec> darts;
  final String description;
  final CheckoutDifficulty difficulty;

  CheckoutSuggestion({
    required this.score,
    required this.darts,
    required this.description,
    required this.difficulty,
  });

  int get dartsRequired => darts.length;
  int get totalPoints => darts.fold(0, (sum, dart) => sum + dart.points);

  bool get isSingleDart => darts.length == 1;
  bool get isDoubleDart => darts.length == 2;
  bool get isThreeDart => darts.length == 3;

  @override
  String toString() => description;
}
