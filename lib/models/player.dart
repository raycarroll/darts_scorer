class Player {
  final String id;
  final String gameId;
  final String name;
  final int orderPosition;
  final int currentScore;
  final bool isActive;

  Player({
    required this.id,
    required this.gameId,
    required this.name,
    required this.orderPosition,
    required this.currentScore,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'game_id': gameId,
      'name': name,
      'order_position': orderPosition,
      'current_score': currentScore,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as String,
      gameId: map['game_id'] as String,
      name: map['name'] as String,
      orderPosition: map['order_position'] as int,
      currentScore: map['current_score'] as int,
      isActive: map['is_active'] == 1,
    );
  }

  Player copyWith({
    String? id,
    String? gameId,
    String? name,
    int? orderPosition,
    int? currentScore,
    bool? isActive,
  }) {
    return Player(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      name: name ?? this.name,
      orderPosition: orderPosition ?? this.orderPosition,
      currentScore: currentScore ?? this.currentScore,
      isActive: isActive ?? this.isActive,
    );
  }
}
