import 'entity.dart';
import 'storage.dart';

class Dependency extends Entity {
  final DependencyPassport passport;

  Dependency(
    this.passport,
    super.name,
    super.type,
  );

  @override
  Identity<Entity> get identity => passport.identity;
}
