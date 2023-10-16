import 'entity.dart';
import 'entity_type.dart';
import 'storage.dart';

abstract interface class ActiveRecordStorage {
  bool get disposed;
  void changeName(EntityPassport entity, String name);
  void changeType(EntityPassport entity, EntityType type);
  void changeImportance(EntityPassport entity, int value);
  void toggleCompromised(EntityPassport entity, bool value);
  void toggleLost(EntityPassport entity, bool value);
  void addDependency(FactorPassport factor, Identity<Entity> entity);
  void addFactor(EntityPassport entity);
  void mergeFactors(FactorPassport into, FactorPassport from);
  void addDependencyAsFactor(
    EntityPassport entity,
    Identity<Entity> dependency,
  );
  void removeDependency(DependencyPassport dependency);
  void moveDependency(DependencyPassport dependency, FactorPassport factor);
  void moveDependencyAsFactor(
    DependencyPassport dependency,
    EntityPassport entity,
  );
}
