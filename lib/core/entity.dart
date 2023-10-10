import 'entity_type.dart';
import 'storage.dart';

class Entity {
  final Identity<Entity> identity;
  final String name;
  final EntityType type;

  const Entity(
    this.identity,
    this.name,
    this.type,
  );
}
