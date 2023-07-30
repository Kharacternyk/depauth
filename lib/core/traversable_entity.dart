import 'entity.dart';
import 'factor.dart';

class TraversableEntity extends Entity {
  final Iterable<Factor> factors;

  const TraversableEntity(
    super.id,
    super.name,
    super.type, {
    required this.factors,
    required super.lost,
    required super.compromised,
  });
}
