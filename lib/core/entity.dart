import 'db.dart';
import 'entity_type.dart';
import 'trait.dart';

class Entity {
  final Id<Entity> id;
  final String name;
  final EntityType type;
  final Trait lost;
  final Trait compromised;

  const Entity(
    this.id,
    this.name,
    this.type, {
    required this.lost,
    required this.compromised,
  });
}
