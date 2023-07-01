enum EntityType {
  hardwareKey,
  webService,
}

class Entity {
  final EntityType type;
  final String name;

  const Entity({
    required this.type,
    required this.name,
  });
}
