import 'entity.dart';
import 'storage.dart';

class Factor {
  final FactorPassport passport;
  final Iterable<Entity> dependencies;

  const Factor(this.passport, this.dependencies);

  Identity<Factor> get identity => passport.identity;

  bool contains(Identity<Entity> entity) {
    for (final dependency in dependencies) {
      if (dependency.identity == entity) {
        return true;
      }
    }

    return false;
  }
}
