import 'entity.dart';
import 'entity_type.dart';
import 'passportless_entity.dart';
import 'storage.dart';

abstract interface class ActiveRecord {
  bool get disposed;

  PassportlessEntity? getPassportlessEntity(Identity<Entity> identity);

  void changeName(EntityPassport entity, String name);
  void changeType(EntityPassport entity, EntityType type);
  void changeImportance(EntityPassport entity, int value);
  void toggleCompromised(EntityPassport entity, bool value);
  void toggleLost(EntityPassport entity, bool value);
  void addNote(EntityPassport entity, String note);
  void changeNote(EntityPassport entity, String note);
  void removeNote(EntityPassport entity);
  void addDependency(FactorPassport factor, Identity<Entity> entity);
  void addFactor(EntityPassport entity);
  void changeThreshold(FactorPassport factor, int value);
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
