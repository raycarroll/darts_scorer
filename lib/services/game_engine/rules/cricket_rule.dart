import 'package:darts_scorer/models/game_type.dart';
import 'package:darts_scorer/models/dart.dart';
import 'package:darts_scorer/models/multiplier.dart';
import 'package:darts_scorer/models/checkout_suggestion.dart';
import 'game_rule.dart';

class CricketRule implements GameRule {
  // Cricket uses numbers 15-20 and bulls (25)
  static const List<int> validZones = [15, 16, 17, 18, 19, 20, 25];

  // Store player states: playerId -> CricketPlayerState
  final Map<String, CricketPlayerState> _playerStates = {};

  CricketRule();

  void initializePlayer(String playerId) {
    _playerStates[playerId] = CricketPlayerState();
  }

  CricketPlayerState getPlayerState(String playerId) {
    return _playerStates[playerId] ?? CricketPlayerState();
  }

  @override
  GameType get gameType => GameType.cricket;

  @override
  int get startingScore => 0; // Cricket uses points, not countdown

  @override
  int? calculateScore(int currentScore, Dart dart) {
    // Cricket doesn't use traditional scoring
    // Score management is handled separately through player states
    return currentScore;
  }

  @override
  bool isWinningDart(int currentScore, Dart dart) {
    // Winning condition is checked separately
    // A player wins when all their numbers are closed AND they have the most points
    return false;
  }

  @override
  bool isBust(int currentScore, Dart dart) {
    // No busts in Cricket
    return false;
  }

  @override
  bool canFinishFrom(int score, int dartsRemaining) {
    // Cricket doesn't have traditional finish detection
    return false;
  }

  @override
  List<CheckoutSuggestion> getCheckoutSuggestions(int score, int dartsRemaining) {
    // No checkout suggestions for Cricket
    return [];
  }

  // Cricket-specific methods
  void recordDartForPlayer(String playerId, Dart dart, List<String> opponentIds) {
    final playerState = getPlayerState(playerId);

    if (!validZones.contains(dart.zone)) {
      return; // Invalid zone for Cricket
    }

    final marksToAdd = _getMarksForDart(dart);
    final currentMarks = playerState.marks[dart.zone] ?? 0;
    final newMarks = currentMarks + marksToAdd;

    if (newMarks <= 3) {
      // Just adding marks, not closed yet
      playerState.marks[dart.zone] = newMarks;
    } else {
      // Number is closed, score points if opponents haven't closed it
      playerState.marks[dart.zone] = 3;

      final extraMarks = newMarks - 3;
      if (!_isClosedByAllOpponents(dart.zone, opponentIds)) {
        // Score points: zone value * extra marks
        playerState.points += dart.zone * extraMarks;
      }
    }
  }

  int _getMarksForDart(Dart dart) {
    switch (dart.multiplier) {
      case Multiplier.single:
        return 1;
      case Multiplier.double:
        return 2;
      case Multiplier.triple:
        return 3;
      case Multiplier.outerBull:
        return 1;
      case Multiplier.innerBull:
        return 2;
    }
  }

  bool _isClosedByAllOpponents(int zone, List<String> opponentIds) {
    for (final opponentId in opponentIds) {
      final opponentState = getPlayerState(opponentId);
      if ((opponentState.marks[zone] ?? 0) < 3) {
        return false;
      }
    }
    return true;
  }

  bool hasPlayerWon(String playerId, List<String> opponentIds) {
    final playerState = getPlayerState(playerId);

    // Check if all numbers are closed
    for (final zone in validZones) {
      if ((playerState.marks[zone] ?? 0) < 3) {
        return false;
      }
    }

    // Check if player has most points (or tied for most)
    final playerPoints = playerState.points;
    for (final opponentId in opponentIds) {
      if (getPlayerState(opponentId).points > playerPoints) {
        return false;
      }
    }

    return true;
  }
}

class CricketPlayerState {
  final Map<int, int> marks; // zone -> mark count (0-3)
  int points;

  CricketPlayerState()
      : marks = {},
        points = 0;

  bool isClosed(int zone) => (marks[zone] ?? 0) >= 3;

  int getMarks(int zone) => marks[zone] ?? 0;
}
