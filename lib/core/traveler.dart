import 'entity.dart';
import 'storage.dart';

sealed class GrabbableTraveler {}

sealed class DeletableTraveler {}

sealed class DependableTraveler {}

sealed class FactorableTraveler {}

class EntityTraveler
    implements
        GrabbableTraveler,
        DeletableTraveler,
        DependableTraveler,
        FactorableTraveler {
  final Passport passport;

  const EntityTraveler(this.passport);
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
  final FactorPassport factor;
  final Identity<Entity> entity;

  const DependencyTraveler(this.factor, this.entity);
}

class StorageTraveler implements DeletableTraveler {
  final String storageName;

  const StorageTraveler(this.storageName);
}
