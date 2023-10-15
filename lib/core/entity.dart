import 'entity_type.dart';
import 'storage.dart';

abstract class Entity {
  Identity<Entity> get identity;
  final String name;
  final EntityType type;

  const Entity(
    this.name,
    this.type,
  );
}
