class Position {
  final int x;
  final int y;

  const Position(this.x, this.y);

  @override
  operator ==(other) => other is Position && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);
}
