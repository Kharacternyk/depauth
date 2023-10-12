import 'entity.dart';
import 'storage.dart';

class Factor {
  final FactorPassport passport;
  final Iterable<Entity> dependencies;

  const Factor(this.passport, this.dependencies);

  Identity<Factor> get identity => passport.identity;
}
