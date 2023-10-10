import 'embellished_entity.dart';
import 'factor.dart';

class TraversableEntity extends EmbellishedEntity {
  final Iterable<Factor> factors;

  const TraversableEntity(
    super.identity,
    super.name,
    super.type, {
    required this.factors,
    required super.lost,
    required super.compromised,
    required super.importance,
  });
}
