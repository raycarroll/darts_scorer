# Checkout Calculator API Contract

**Module**: `lib/services/checkout_calculator/`
**Version**: 1.0
**Date**: 2025-10-23

## Overview

The CheckoutCalculator is responsible for finding valid dart combinations to finish a game from a given score. It provides checkout suggestions ordered by difficulty and feasibility.

## Public Interface

### CheckoutCalculator Class

```dart
abstract class CheckoutCalculator {
  /// Finds all valid checkout combinations for a given score
  ///
  /// Parameters:
  ///   - score: Remaining score to finish from (2-170)
  ///   - dartsAvailable: Number of darts available in turn (1-3)
  ///   - mustFinishOnDouble: Whether finish must be on a double (default: true)
  ///
  /// Returns: List of CheckoutSuggestion ordered by difficulty (easiest first)
  ///
  /// Returns empty list if:
  ///   - Score is impossible to finish (e.g., 169, 168, 166, etc.)
  ///   - Score exceeds maximum checkout (170 with 3 darts)
  ///   - Not enough darts available for the score
  List<CheckoutSuggestion> findCheckouts({
    required int score,
    required int dartsAvailable,
    bool mustFinishOnDouble = true,
  });

  /// Checks if a score can be finished with available darts
  ///
  /// Parameters:
  ///   - score: Remaining score to check
  ///   - dartsAvailable: Number of darts available (1-3)
  ///   - mustFinishOnDouble: Whether finish must be on a double
  ///
  /// Returns: true if score is finishable, false otherwise
  bool isFinishable({
    required int score,
    required int dartsAvailable,
    bool mustFinishOnDouble = true,
  });

  /// Gets the best (easiest) checkout for a score
  ///
  /// Parameters:
  ///   - score: Remaining score
  ///   - dartsAvailable: Number of darts available (1-3)
  ///   - mustFinishOnDouble: Whether finish must be on a double
  ///
  /// Returns: Best CheckoutSuggestion, or null if impossible
  CheckoutSuggestion? getBestCheckout({
    required int score,
    required int dartsAvailable,
    bool mustFinishOnDouble = true,
  });

  /// Gets the maximum possible checkout with N darts
  ///
  /// Parameters:
  ///   - dartsAvailable: Number of darts (1-3)
  ///   - mustFinishOnDouble: Whether finish must be on a double
  ///
  /// Returns: Maximum finishable score
  ///   - 1 dart: 50 (Bull)
  ///   - 2 darts: 110 (T20 + Bull)
  ///   - 3 darts: 170 (T20 + T20 + Bull)
  int getMaxCheckout({
    required int dartsAvailable,
    bool mustFinishOnDouble = true,
  });
}
```

## Data Structures

### CheckoutSuggestion

```dart
class CheckoutSuggestion {
  final int score;                    // Score this checkout finishes from
  final List<DartSpec> darts;         // Ordered list of darts to throw
  final String description;           // Human-readable (e.g., "T20-T20-Bull")
  final CheckoutDifficulty difficulty;// Difficulty rating

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
```

### DartSpec

```dart
class DartSpec {
  final int zone;              // 1-20 or 25 (bull)
  final Multiplier multiplier; // single, double, triple, outerBull, innerBull

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
```

### CheckoutDifficulty

```dart
enum CheckoutDifficulty {
  easy,        // Single dart double (D20, D25, Bull)
  moderate,    // Two dart with big targets (T20-D20, etc.)
  challenging, // Two dart small targets or three dart big targets
  hard,        // Three dart mixed targets
  expert,      // Complex three dart (T20-T20-Bull, etc.)
}

extension CheckoutDifficultyExtension on CheckoutDifficulty {
  int get rating {
    switch (this) {
      case CheckoutDifficulty.easy: return 1;
      case CheckoutDifficulty.moderate: return 2;
      case CheckoutDifficulty.challenging: return 3;
      case CheckoutDifficulty.hard: return 4;
      case CheckoutDifficulty.expert: return 5;
    }
  }
}
```

## Checkout Database

### Pre-computed Checkouts

The system maintains a pre-computed database of common checkouts:

```dart
class CheckoutDatabase {
  /// Gets pre-computed checkouts for a score
  ///
  /// Returns null if not in database (must compute algorithmically)
  List<CheckoutSuggestion>? getCheckouts(int score);

  /// Checks if database has checkouts for score
  bool hasCheckouts(int score);

  /// Gets all scores in the database
  Set<int> getAvailableScores();
}
```

### Database Coverage

Pre-computed checkouts for all finishable scores 2-170:

- **1 dart finishes** (2-50 even): D1, D2, ..., D25, Bull
- **2 dart finishes** (51-110): T20-D20, T19-D17, etc.
- **3 dart finishes** (111-170): T20-T20-Bull, T20-T19-D20, etc.

### Impossible Finishes

Scores that cannot be finished with double-out rule:

```dart
const impossibleFinishes = {
  1,    // Cannot finish on 1 (no D0.5)
  169,  // T20(60) + T20(60) + D20(40) = 160, T20 + T19(57) + Bull(50) = 167
  168,  // Similar impossible combinations
  166,  // Similar impossible combinations
  165,  // Similar impossible combinations
  163,  // Similar impossible combinations
  162,  // Similar impossible combinations
  159,  // Similar impossible combinations
};
```

## Algorithm

### Lookup Strategy

```dart
List<CheckoutSuggestion> findCheckouts({
  required int score,
  required int dartsAvailable,
  bool mustFinishOnDouble = true,
}) {
  // 1. Check if score is possible
  if (score < 2 || score > getMaxCheckout(dartsAvailable: dartsAvailable)) {
    return [];
  }

  if (impossibleFinishes.contains(score)) {
    return [];
  }

  // 2. Try database lookup first (O(1))
  var checkouts = _database.getCheckouts(score);
  if (checkouts != null) {
    // Filter by darts available
    checkouts = checkouts.where((c) => c.dartsRequired <= dartsAvailable).toList();
    // Sort by difficulty
    checkouts.sort((a, b) => a.difficulty.rating.compareTo(b.difficulty.rating));
    return checkouts;
  }

  // 3. Compute algorithmically (rare case)
  return _computeCheckouts(score, dartsAvailable, mustFinishOnDouble);
}
```

### Algorithmic Computation

For scores not in database:

```dart
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
  if (dartsAvailable >= 2) {
    checkouts.addAll(_findTwoDartCheckouts(score, mustFinishOnDouble));
  }

  // Try 3-dart finishes
  if (dartsAvailable >= 3) {
    checkouts.addAll(_findThreeDartCheckouts(score, mustFinishOnDouble));
  }

  // Sort by difficulty
  checkouts.sort((a, b) => a.difficulty.rating.compareTo(b.difficulty.rating));

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

  // Try all combinations: first dart (S, D, T on 1-20) + finish dart (D on 1-20 or Bull)
  for (var firstDart in _allPossibleDarts(includeDoubles: false)) {
    int remaining = score - firstDart.points;

    // Must finish on double
    for (var finishDart in _allPossibleFinishDarts()) {
      if (finishDart.points == remaining) {
        checkouts.add(CheckoutSuggestion(
          score: score,
          darts: [firstDart, finishDart],
          description: '${firstDart.notation}-${finishDart.notation}',
          difficulty: _calculateDifficulty([firstDart, finishDart]),
        ));
      }
    }
  }

  return checkouts;
}

List<CheckoutSuggestion> _findThreeDartCheckouts(int score, bool mustFinishOnDouble) {
  final checkouts = <CheckoutSuggestion>[];

  // Try all combinations: dart1 + dart2 + finish dart (double)
  for (var dart1 in _allPossibleDarts(includeDoubles: false)) {
    for (var dart2 in _allPossibleDarts(includeDoubles: false)) {
      int remaining = score - dart1.points - dart2.points;

      for (var finishDart in _allPossibleFinishDarts()) {
        if (finishDart.points == remaining) {
          checkouts.add(CheckoutSuggestion(
            score: score,
            darts: [dart1, dart2, finishDart],
            description: '${dart1.notation}-${dart2.notation}-${finishDart.notation}',
            difficulty: _calculateDifficulty([dart1, dart2, finishDart]),
          ));
        }
      }
    }
  }

  return checkouts;
}
```

### Difficulty Calculation

```dart
CheckoutDifficulty _calculateDifficulty(List<DartSpec> darts) {
  // 1 dart: always easy
  if (darts.length == 1) {
    return CheckoutDifficulty.easy;
  }

  // 2 darts
  if (darts.length == 2) {
    // Big doubles (D16-D20, Bull): moderate
    if (_hasBigDoubles(darts)) {
      return CheckoutDifficulty.moderate;
    }
    // Small doubles (D1-D15): challenging
    return CheckoutDifficulty.challenging;
  }

  // 3 darts
  if (darts.length == 3) {
    // All triples or bull: expert
    if (_hasMultipleTriples(darts)) {
      return CheckoutDifficulty.expert;
    }
    // Mix of targets: hard
    return CheckoutDifficulty.hard;
  }

  return CheckoutDifficulty.hard;
}
```

## Behavior Contracts

### Finishability Rules

1. **Score too low**: Scores < 2 are unfinishable
2. **Score too high**: Scores > max checkout for darts available are unfinishable
3. **Impossible scores**: Certain odd scores > 50 are mathematically impossible
4. **Must finish on double**: Final dart must be D1-D20 or Bull (if mustFinishOnDouble=true)

### Checkout Ordering

Checkouts are returned ordered by difficulty:

1. **Easy** (1-dart doubles)
2. **Moderate** (2-dart with big targets)
3. **Challenging** (2-dart with small targets, 3-dart with big targets)
4. **Hard** (3-dart mixed targets)
5. **Expert** (3-dart complex combinations)

Within same difficulty, prefer:
1. Fewer darts required
2. Higher finishing double (D20 > D10)
3. Common/favorite combinations (T20 preferred)

### Maximum Checkouts

| Darts Available | Maximum Checkout | Combination |
|-----------------|------------------|-------------|
| 1 dart | 50 | Bull |
| 2 darts | 110 | T20 + Bull |
| 3 darts | 170 | T20 + T20 + Bull |

## Error Handling

### No Exceptions Thrown

CheckoutCalculator never throws exceptions. Invalid inputs return empty lists:

- `score < 2`: Returns `[]`
- `score > 170`: Returns `[]`
- `dartsAvailable < 1 or > 3`: Returns `[]`
- `impossibleFinishes.contains(score)`: Returns `[]`

## Dependencies

### No External Dependencies

CheckoutCalculator is a pure calculation service with no dependencies on:
- Database (uses in-memory checkout database)
- Game state
- Other services

Can be tested in complete isolation.

## Testing Contract

### Unit Tests Required

1. `test_findCheckouts_singleDartDouble_success()`
2. `test_findCheckouts_bull50_success()`
3. `test_findCheckouts_twoDart_multipleOptions()`
4. `test_findCheckouts_threeDart170_success()`
5. `test_findCheckouts_impossibleScore_returnsEmpty()`
6. `test_findCheckouts_scoreTooHigh_returnsEmpty()`
7. `test_isFinishable_finishableScore_returnsTrue()`
8. `test_isFinishable_impossibleScore_returnsFalse()`
9. `test_getBestCheckout_returnsEasiest()`
10. `test_getMaxCheckout_oneDart_returns50()`
11. `test_getMaxCheckout_threeDarts_returns170()`

### Data Tests Required

1. `test_database_allScores2to170_haveCheckouts()`
2. `test_database_impossibleScores_returnEmpty()`
3. `test_database_checkoutValidity_allEntriesValid()`

## Performance Contracts

- `findCheckouts()` with database hit: < 10ms
- `findCheckouts()` with algorithm: < 100ms
- `isFinishable()`: < 5ms (simple lookup/calculation)
- `getBestCheckout()`: < 10ms
- Database initialization: < 50ms at app startup

## Database Format

### In-Memory Map

```dart
final Map<int, List<CheckoutSuggestion>> _checkoutDatabase = {
  2: [
    CheckoutSuggestion(
      score: 2,
      darts: [DartSpec(1, Multiplier.double)],
      description: 'D1',
      difficulty: CheckoutDifficulty.easy,
    ),
  ],
  40: [
    CheckoutSuggestion(
      score: 40,
      darts: [DartSpec(20, Multiplier.double)],
      description: 'D20',
      difficulty: CheckoutDifficulty.easy,
    ),
    CheckoutSuggestion(
      score: 40,
      darts: [DartSpec(10, Multiplier.double)],
      description: 'D10',
      difficulty: CheckoutDifficulty.moderate,
    ),
  ],
  170: [
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
  ],
  // ... all scores 2-170
};
```

### Database Size

- ~500 unique scores with checkouts
- Average 3 suggestions per score
- ~1,500 total entries
- Each entry: ~100 bytes
- **Total size**: ~150KB in memory (negligible)

---

**Contract version**: 1.0
**Last updated**: 2025-10-23
