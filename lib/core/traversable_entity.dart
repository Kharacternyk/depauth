import 'entity.dart';

class TraversableEntity extends Entity {
  final Iterable<Iterable<Entity>> dependencies;

  const TraversableEntity(super.name, super.type, this.dependencies);
}
