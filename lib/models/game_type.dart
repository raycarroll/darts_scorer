enum GameType {
  fiveOhOne('501', 501),
  threeOhOne('301', 301),
  cricket('Cricket', 0),
  aroundClock('Around the Clock', 0);

  const GameType(this.displayName, this.startingScore);

  final String displayName;
  final int startingScore;
}
