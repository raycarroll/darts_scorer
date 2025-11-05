class Turn {
  final String id;
  final String playerId;
  final int roundNumber;
  final int turnNumber;
  final DateTime createdAt;

  Turn({
    required this.id,
    required this.playerId,
    required this.roundNumber,
    required this.turnNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'player_id': playerId,
      'round_number': roundNumber,
      'turn_number': turnNumber,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Turn.fromMap(Map<String, dynamic> map) {
    return Turn(
      id: map['id'] as String,
      playerId: map['player_id'] as String,
      roundNumber: map['round_number'] as int,
      turnNumber: map['turn_number'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Turn copyWith({
    String? id,
    String? playerId,
    int? roundNumber,
    int? turnNumber,
    DateTime? createdAt,
  }) {
    return Turn(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      roundNumber: roundNumber ?? this.roundNumber,
      turnNumber: turnNumber ?? this.turnNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
