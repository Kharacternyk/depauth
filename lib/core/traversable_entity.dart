import 'entity.dart';
import 'factor.dart';
import 'storage.dart';

class TraversableEntity extends Entity {
  final EntityPassport passport;
  final Iterable<Factor> factors;
  final int importance;

  TraversableEntity(
    this.passport,
    super.name,
    super.type, {
    required this.factors,
    required this.importance,
  });

  @override
  Identity<Entity> get identity => passport.identity;
}
