import 'entity.dart';
import 'storage.dart';

sealed class GrabbableTraveler {}

sealed class DeletableTraveler {}

sealed class DependableTraveler {
  Identity<Entity> get entity;
}

sealed class FactorableTraveler {}

class EntityTraveler
    implements
        GrabbableTraveler,
        DeletableTraveler,
        DependableTraveler,
        FactorableTraveler {
  final Passport passport;

  const EntityTraveler(this.passport);

  @override
  Identity<Entity> get entity => passport.identity;
}

class CreationTraveler implements GrabbableTraveler, FactorableTraveler {
  const CreationTraveler();
}

class FactorTraveler implements DeletableTraveler {
  final FactorPassport passport;

  const FactorTraveler(this.passport);
}

class DependencyTraveler
    implements DeletableTraveler, DependableTraveler, FactorableTraveler {
  @override
  final Identity<Entity> entity;
  final FactorPassport factor;

  const DependencyTraveler(this.factor, this.entity);
}

class StorageTraveler implements DeletableTraveler {
  final String storageName;

  const StorageTraveler(this.storageName);
}
