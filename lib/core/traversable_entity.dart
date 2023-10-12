import 'entity.dart';
import 'entity_type.dart';
import 'factor.dart';
import 'storage.dart';

class TraversableEntity extends Entity {
  final Passport passport;
  final Iterable<Factor> factors;
  final bool lost;
  final bool compromised;
  final int importance;

  TraversableEntity(
    this.passport,
    String name,
    EntityType type, {
    required this.factors,
    required this.lost,
    required this.compromised,
    required this.importance,
  }) : super(passport.identity, name, type);
}
