import 'db.dart';
import 'entity.dart';
import 'factor.dart';
import 'position.dart';

sealed class GrabbableTraveler {}

sealed class DeletableTraveler {}

sealed class DependableTraveler {}

class EntityTraveler
    implements GrabbableTraveler, DeletableTraveler, DependableTraveler {
  final Position position;
  final Id<Entity> id;

  const EntityTraveler(this.position, this.id);
}

class CreationTraveler implements GrabbableTraveler {
  const CreationTraveler();
}

class FactorTraveler implements DeletableTraveler {
  final Position position;
  final Id<Factor> id;

  const FactorTraveler(this.position, this.id);
}

class DependencyTraveler implements DeletableTraveler, DependableTraveler {
  final Position position;
  final Id<Factor> factorId;
  final Id<Entity> entityId;

  const DependencyTraveler(this.position, this.factorId, this.entityId);
}
