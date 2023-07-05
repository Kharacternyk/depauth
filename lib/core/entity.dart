import 'fraction.dart';

enum EntityType {
  hardwareKey,
  webService,
  person,
}

class Entity {
  final EntityType type;
  final String name;
  final Map<String, Fraction> dependsOn;

  const Entity({
    required this.type,
    required this.name,
    this.dependsOn = const {},
  });
}
