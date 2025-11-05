import 'package:darts_scorer/models/game_type.dart';
import 'package:darts_scorer/models/dart.dart';
import 'package:darts_scorer/models/checkout_suggestion.dart';
import 'game_rule.dart';

class AroundClockRule implements GameRule {
  // Store each player's current target: playerId -> current target number
  final Map<String, int> _playerTargets = {};

  AroundClockRule();

  void initializePlayer(String playerId) {
    _playerTargets[playerId] = 1; // Start at 1
  }

  int getCurrentTarget(String playerId) {
    return _playerTargets[playerId] ?? 1;
  }

  @override
  GameType get gameType => GameType.aroundClock;

  @override
  int get startingScore => 1; // Represents current target number

  @override
  int? calculateScore(int currentScore, Dart dart) {
    // Score represents current target in Around the Clock
    // This will be managed separately
    return currentScore;
  }

  @override
  bool isWinningDart(int currentScore, Dart dart) {
    // Player wins when they hit the bullseye after completing 1-20
    return currentScore == 21 && dart.zone == 25;
  }

  @override
  bool isBust(int currentScore, Dart dart) {
    // No busts in Around the Clock
    return false;
  }

  @override
  bool canFinishFrom(int score, int dartsRemaining) {
    // Can finish if on target 21 (bullseye) with darts remaining
    return score == 21 && dartsRemaining > 0;
  }

  @override
  List<CheckoutSuggestion> getCheckoutSuggestions(int score, int dartsRemaining) {
    // No traditional checkout suggestions
    return [];
  }

  // Around the Clock specific methods
  bool recordDartForPlayer(String playerId, Dart dart) {
    final currentTarget = getCurrentTarget(playerId);

    // Check if dart hit the current target
    if (dart.zone == currentTarget) {
      // Hit! Advance to next target
      if (currentTarget == 20) {
        _playerTargets[playerId] = 21; // Move to bullseye
      } else if (currentTarget == 21 && dart.zone == 25) {
        _playerTargets[playerId] = 22; // Won!
        return true; // Winning dart
      } else {
        _playerTargets[playerId] = currentTarget + 1;
      }
    }
    // If didn't hit target, no advancement

    return false; // Not a winning dart
  }

  bool hasPlayerWon(String playerId) {
    return getCurrentTarget(playerId) >= 22; // Completed through bullseye
  }
}
