import 'entity_type.dart';

class Entity {
  final String name;
  final EntityType type;
  final bool lost;
  final bool compromised;

  const Entity(
    this.name,
    this.type, {
    required this.lost,
    required this.compromised,
  });
}
