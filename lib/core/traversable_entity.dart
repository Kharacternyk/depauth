import 'entity.dart';
import 'factor.dart';
import 'storage.dart';

class TraversableEntity extends Entity {
  final EntityPassport passport;
  final Iterable<Factor> factors;
  final String? note;

  TraversableEntity(
    this.passport,
    super.name,
    super.type,
    this.factors,
    this.note,
  );

  @override
  Identity<Entity> get identity => passport.identity;
}
