class CricketState {
  final Map<int, int> marks; // zone -> mark count (1-3)
  final int points;

  CricketState({
    required this.marks,
    required this.points,
  });

  CricketState.initial()
      : marks = {},
        points = 0;

  bool isClosed(int zone) => (marks[zone] ?? 0) >= 3;

  int getMarks(int zone) => marks[zone] ?? 0;

  CricketState copyWith({
    Map<int, int>? marks,
    int? points,
  }) {
    return CricketState(
      marks: marks ?? Map.from(this.marks),
      points: points ?? this.points,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'marks': marks,
      'points': points,
    };
  }

  factory CricketState.fromMap(Map<String, dynamic> map) {
    return CricketState(
      marks: Map<int, int>.from(map['marks'] as Map),
      points: map['points'] as int,
    );
  }
}
