import 'package:flutter_test/flutter_test.dart';
import 'package:darts_scorer/models/game_type.dart';
import 'package:darts_scorer/models/dart.dart';
import 'package:darts_scorer/models/multiplier.dart';
import 'package:darts_scorer/services/game_engine/rules/three_oh_one_rule.dart';
import 'package:darts_scorer/services/checkout_calculator/checkout_calculator.dart';

void main() {
  late ThreeOhOneRule rule;

  setUp(() {
    final checkoutCalc = CheckoutCalculatorImpl();
    rule = ThreeOhOneRule(checkoutCalc);
  });

  group('301 Game Rule', () {
    test('starting score is 301', () {
      expect(rule.startingScore, equals(301));
    });

    test('game type is threeOhOne', () {
      expect(rule.gameType, equals(GameType.threeOhOne));
    });

    test('score goes below 0 is bust', () {
      final dart = Dart(
        id: 'test',
        turnId: 'turn1',
        dartNumber: 1,
        zone: 20,
        multiplier: Multiplier.triple,
        points: 60,
      );

      expect(rule.isBust(20, dart), isTrue);
    });

    test('score equals 1 is bust', () {
      final dart = Dart(
        id: 'test',
        turnId: 'turn1',
        dartNumber: 1,
        zone: 2,
        multiplier: Multiplier.single,
        points: 2,
      );

      expect(rule.isBust(3, dart), isTrue);
    });

    test('finish on non-double is bust', () {
      final dart = Dart(
        id: 'test',
        turnId: 'turn1',
        dartNumber: 1,
        zone: 20,
        multiplier: Multiplier.single,
        points: 20,
      );

      expect(rule.isBust(20, dart), isTrue);
    });

    test('finish on double is winning dart', () {
      final dart = Dart(
        id: 'test',
        turnId: 'turn1',
        dartNumber: 1,
        zone: 10,
        multiplier: Multiplier.double,
        points: 20,
      );

      expect(rule.isWinningDart(0, dart), isTrue);
      expect(rule.isBust(20, dart), isFalse);
    });

    test('calculateScore returns correct new score', () {
      final dart = Dart(
        id: 'test',
        turnId: 'turn1',
        dartNumber: 1,
        zone: 20,
        multiplier: Multiplier.triple,
        points: 60,
      );

      expect(rule.calculateScore(301, dart), equals(241));
    });

    test('calculateScore returns null for bust', () {
      final dart = Dart(
        id: 'test',
        turnId: 'turn1',
        dartNumber: 1,
        zone: 20,
        multiplier: Multiplier.triple,
        points: 60,
      );

      expect(rule.calculateScore(20, dart), isNull);
    });
  });
}
