import 'entity.dart';
import 'factor.dart';
import 'storage.dart';

class TraversableEntity extends Entity {
  final EntityPassport passport;
  final Iterable<Factor> factors;

  TraversableEntity(this.passport, super.name, super.type, this.factors);

  @override
  Identity<Entity> get identity => passport.identity;
}
