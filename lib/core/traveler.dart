import 'entity.dart';
import 'factor.dart';
import 'position.dart';
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
  final Position position;
  final Identity<Entity> entity;

  const EntityTraveler(this.position, this.entity);
}

class CreationTraveler implements GrabbableTraveler, FactorableTraveler {
  const CreationTraveler();
}

class FactorTraveler implements DeletableTraveler {
  final Position position;
  final Identity<Factor> factor;

  const FactorTraveler(this.position, this.factor);
}

class DependencyTraveler
    implements DeletableTraveler, DependableTraveler, FactorableTraveler {
  final Position position;
  final Identity<Factor> factor;
  final Identity<Entity> entity;

  const DependencyTraveler(this.position, this.factor, this.entity);
}
