import 'dependency.dart';
import 'entity.dart';
import 'storage.dart';

class Factor {
  final FactorPassport passport;
  final Iterable<Dependency> dependencies;
  final int threshold;

  const Factor(this.passport, this.dependencies, this.threshold);

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
