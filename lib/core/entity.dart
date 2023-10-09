import 'entity_type.dart';
import 'storage.dart';

class Entity {
  final Identity<Entity> identity;
  final String name;
  final EntityType type;
  final bool lost;
  final bool compromised;
  final int importance;

  const Entity(
    this.identity,
    this.name,
    this.type, {
    required this.lost,
    required this.compromised,
    required this.importance,
  });
}
