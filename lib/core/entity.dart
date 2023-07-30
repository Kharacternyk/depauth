import 'db.dart';
import 'entity_type.dart';

class Entity {
  final Id<Entity> id;
  final String name;
  final EntityType type;
  final bool lost;
  final bool compromised;

  const Entity(
    this.id,
    this.name,
    this.type, {
    required this.lost,
    required this.compromised,
  });
}
