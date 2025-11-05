import 'multiplier.dart';

class Dart {
  final String id;
  final String turnId;
  final int dartNumber;
  final int zone;
  final Multiplier multiplier;
  final int points;

  Dart({
    required this.id,
    required this.turnId,
    required this.dartNumber,
    required this.zone,
    required this.multiplier,
    required this.points,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'turn_id': turnId,
      'dart_number': dartNumber,
      'zone': zone,
      'multiplier': multiplier.name,
      'points': points,
    };
  }

  factory Dart.fromMap(Map<String, dynamic> map) {
    return Dart(
      id: map['id'] as String,
      turnId: map['turn_id'] as String,
      dartNumber: map['dart_number'] as int,
      zone: map['zone'] as int,
      multiplier: Multiplier.values.byName(map['multiplier'] as String),
      points: map['points'] as int,
    );
  }

  // Factory constructors for common dart types
  factory Dart.single(String id, String turnId, int dartNum, int zone) {
    return Dart(
      id: id,
      turnId: turnId,
      dartNumber: dartNum,
      zone: zone,
      multiplier: Multiplier.single,
      points: zone * 1,
    );
  }

  factory Dart.double(String id, String turnId, int dartNum, int zone) {
    return Dart(
      id: id,
      turnId: turnId,
      dartNumber: dartNum,
      zone: zone,
      multiplier: Multiplier.double,
      points: zone * 2,
    );
  }

  factory Dart.triple(String id, String turnId, int dartNum, int zone) {
    return Dart(
      id: id,
      turnId: turnId,
      dartNumber: dartNum,
      zone: zone,
      multiplier: Multiplier.triple,
      points: zone * 3,
    );
  }

  factory Dart.outerBull(String id, String turnId, int dartNum) {
    return Dart(
      id: id,
      turnId: turnId,
      dartNumber: dartNum,
      zone: 25,
      multiplier: Multiplier.outerBull,
      points: 25,
    );
  }

  factory Dart.innerBull(String id, String turnId, int dartNum) {
    return Dart(
      id: id,
      turnId: turnId,
      dartNumber: dartNum,
      zone: 25,
      multiplier: Multiplier.innerBull,
      points: 50,
    );
  }

  factory Dart.miss(String id, String turnId, int dartNum) {
    return Dart(
      id: id,
      turnId: turnId,
      dartNumber: dartNum,
      zone: 0,
      multiplier: Multiplier.single,
      points: 0,
    );
  }

  Dart copyWith({
    String? id,
    String? turnId,
    int? dartNumber,
    int? zone,
    Multiplier? multiplier,
    int? points,
  }) {
    return Dart(
      id: id ?? this.id,
      turnId: turnId ?? this.turnId,
      dartNumber: dartNumber ?? this.dartNumber,
      zone: zone ?? this.zone,
      multiplier: multiplier ?? this.multiplier,
      points: points ?? this.points,
    );
  }
}
