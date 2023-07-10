enum EntityType {
  webService,
  hardwareKey,
  person,
}

class Position {
  final int x;
  final int y;

  const Position(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      other is Position && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);
}

class Boundaries {
  final Position start;
  final Position end;

  const Boundaries(this.start, this.end);
}

class EntityId {
  final int value;

  const EntityId(this.value);

  @override
  bool operator ==(Object other) => other is EntityId && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class Entity {
  final String name;
  final EntityType type;

  const Entity(this.name, this.type);
}
