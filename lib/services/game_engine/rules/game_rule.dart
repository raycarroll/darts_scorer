import 'package:darts_scorer/models/game_type.dart';
import 'package:darts_scorer/models/dart.dart';
import 'package:darts_scorer/models/checkout_suggestion.dart';

abstract class GameRule {
  GameType get gameType;
  int get startingScore;

  int? calculateScore(int currentScore, Dart dart);
  bool isWinningDart(int currentScore, Dart dart);
  bool isBust(int currentScore, Dart dart);
  bool canFinishFrom(int score, int dartsRemaining);
  List<CheckoutSuggestion> getCheckoutSuggestions(int score, int dartsRemaining);
}
