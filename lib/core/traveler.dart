import 'db.dart';
import 'factor.dart';
import 'position.dart';

sealed class SourceTraveler {}

sealed class DeletableTraveler {}

class EntityTraveler implements SourceTraveler, DeletableTraveler {
  final Position position;

  const EntityTraveler(this.position);
}

class CreationTraveler implements SourceTraveler {
  const CreationTraveler();
}

class FactorTraveler implements DeletableTraveler {
  final Position position;
  final Id<Factor> id;

  const FactorTraveler(this.position, this.id);
}
