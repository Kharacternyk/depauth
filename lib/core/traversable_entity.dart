import 'factor.dart';
import 'unique_entity.dart';

class TraversableEntity extends UniqueEntity {
  final Iterable<Factor> dependencies;

  const TraversableEntity(super.id, super.name, super.type, this.dependencies);
}
