import 'factor.dart';
import 'unique_entity.dart';

class TraversableEntity extends UniqueEntity {
  final Iterable<Factor> factors;

  const TraversableEntity(super.id, super.name, super.type, this.factors);
}
