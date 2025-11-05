import 'package:darts_scorer/models/checkout_suggestion.dart';
import 'package:darts_scorer/models/multiplier.dart';

class CheckoutDatabase {
  static final CheckoutDatabase _instance = CheckoutDatabase._internal();
  factory CheckoutDatabase() => _instance;
  CheckoutDatabase._internal();

  // Pre-computed checkout database
  final Map<int, List<CheckoutSuggestion>> _checkouts = {};

  // Impossible finishes with must-finish-on-double rule
  static const Set<int> impossibleFinishes = {
    1, 169, 168, 166, 165, 163, 162, 159,
  };

  void initialize() {
    if (_checkouts.isNotEmpty) return;

    // Build checkout database for common scores
    _buildSingleDartCheckouts();
    _buildTwoDartCheckouts();
    _buildThreeDartCheckouts();
  }

  void _buildSingleDartCheckouts() {
    // Even numbers 2-40 (doubles 1-20)
    for (int zone = 1; zone <= 20; zone++) {
      final score = zone * 2;
      _checkouts[score] = [
        CheckoutSuggestion(
          score: score,
          darts: [DartSpec(zone, Multiplier.double)],
          description: 'D$zone',
          difficulty: zone >= 16 ? CheckoutDifficulty.easy : CheckoutDifficulty.moderate,
        ),
      ];
    }

    // Bull (50)
    _checkouts[50] = [
      CheckoutSuggestion(
        score: 50,
        darts: [DartSpec(25, Multiplier.innerBull)],
        description: 'Bull',
        difficulty: CheckoutDifficulty.easy,
      ),
    ];
  }

  void _buildTwoDartCheckouts() {
    // Common two-dart finishes
    final twoDartFinishes = <int, List<List<dynamic>>>{
      60: [[20, Multiplier.single, 20, Multiplier.double]],
      80: [[20, Multiplier.triple, 10, Multiplier.double]],
      90: [[20, Multiplier.triple, 15, Multiplier.double]],
      100: [[20, Multiplier.triple, 20, Multiplier.double]],
      107: [[19, Multiplier.triple, 25, Multiplier.innerBull]],
      110: [[20, Multiplier.triple, 25, Multiplier.innerBull]],
    };

    for (final entry in twoDartFinishes.entries) {
      final score = entry.key;
      final combinations = entry.value;

      _checkouts[score] = combinations.map((combo) {
        final dart1 = DartSpec(combo[0] as int, combo[1] as Multiplier);
        final dart2 = DartSpec(combo[2] as int, combo[3] as Multiplier);

        return CheckoutSuggestion(
          score: score,
          darts: [dart1, dart2],
          description: '${dart1.notation}-${dart2.notation}',
          difficulty: CheckoutDifficulty.moderate,
        );
      }).toList();
    }
  }

  void _buildThreeDartCheckouts() {
    // Common three-dart finishes
    _checkouts[170] = [
      CheckoutSuggestion(
        score: 170,
        darts: [
          DartSpec(20, Multiplier.triple),
          DartSpec(20, Multiplier.triple),
          DartSpec(25, Multiplier.innerBull),
        ],
        description: 'T20-T20-Bull',
        difficulty: CheckoutDifficulty.expert,
      ),
    ];

    _checkouts[167] = [
      CheckoutSuggestion(
        score: 167,
        darts: [
          DartSpec(20, Multiplier.triple),
          DartSpec(19, Multiplier.triple),
          DartSpec(25, Multiplier.innerBull),
        ],
        description: 'T20-T19-Bull',
        difficulty: CheckoutDifficulty.expert,
      ),
    ];

    _checkouts[164] = [
      CheckoutSuggestion(
        score: 164,
        darts: [
          DartSpec(20, Multiplier.triple),
          DartSpec(18, Multiplier.triple),
          DartSpec(25, Multiplier.innerBull),
        ],
        description: 'T20-T18-Bull',
        difficulty: CheckoutDifficulty.expert,
      ),
    ];

    _checkouts[161] = [
      CheckoutSuggestion(
        score: 161,
        darts: [
          DartSpec(20, Multiplier.triple),
          DartSpec(17, Multiplier.triple),
          DartSpec(25, Multiplier.innerBull),
        ],
        description: 'T20-T17-Bull',
        difficulty: CheckoutDifficulty.expert,
      ),
    ];

    _checkouts[160] = [
      CheckoutSuggestion(
        score: 160,
        darts: [
          DartSpec(20, Multiplier.triple),
          DartSpec(20, Multiplier.triple),
          DartSpec(20, Multiplier.double),
        ],
        description: 'T20-T20-D20',
        difficulty: CheckoutDifficulty.expert,
      ),
    ];
  }

  List<CheckoutSuggestion>? getCheckouts(int score) {
    return _checkouts[score];
  }

  bool hasCheckouts(int score) {
    return _checkouts.containsKey(score);
  }

  Set<int> getAvailableScores() {
    return _checkouts.keys.toSet();
  }
}
