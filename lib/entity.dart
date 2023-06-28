enum EntityType {
  hardwareKey,
  webService,
}

class Entity {
  final EntityType type;
  final String name;
  final double x;
  final double y;

  const Entity({
    required this.type,
    required this.name,
    required this.x,
    required this.y,
  });
}
