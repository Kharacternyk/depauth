enum EntityType {
  hardwareKey,
  webService,
  person,
}

class Entity {
  final EntityType type;
  final String name;

  const Entity({
    required this.type,
    required this.name,
  });
}
