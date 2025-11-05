import 'game_type.dart';
import 'game_status.dart';

class Game {
  final String id;
  final GameType gameType;
  final int startingScore;
  final GameStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? winnerId;

  Game({
    required this.id,
    required this.gameType,
    required this.startingScore,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.winnerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'game_type': gameType.name,
      'starting_score': startingScore,
      'status': status.name,
      'created_at': createdAt.millisecondsSinceEpoch,
      'completed_at': completedAt?.millisecondsSinceEpoch,
      'winner_id': winnerId,
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'] as String,
      gameType: GameType.values.byName(map['game_type'] as String),
      startingScore: map['starting_score'] as int,
      status: GameStatus.values.byName(map['status'] as String),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      completedAt: map['completed_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_at'] as int)
          : null,
      winnerId: map['winner_id'] as String?,
    );
  }

  Game copyWith({
    String? id,
    GameType? gameType,
    int? startingScore,
    GameStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? winnerId,
  }) {
    return Game(
      id: id ?? this.id,
      gameType: gameType ?? this.gameType,
      startingScore: startingScore ?? this.startingScore,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      winnerId: winnerId ?? this.winnerId,
    );
  }
}
