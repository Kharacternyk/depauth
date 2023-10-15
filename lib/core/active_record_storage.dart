import 'entity.dart';
import 'entity_type.dart';
import 'storage.dart';

abstract interface class ActiveRecordStorage {
  bool get disposed;
  void changeName(Passport entity, String name);
  void changeType(Passport entity, EntityType type);
  void changeImportance(Passport entity, int value);
  void toggleCompromised(Passport entity, bool value);
  void toggleLost(Passport entity, bool value);
  void addDependency(FactorPassport factor, Identity<Entity> entity);
  void addFactor(Passport entity);
  void addDependencyAsFactor(
    Passport entity,
    Identity<Entity> dependency,
  );
  void removeDependency(FactorPassport factor, Identity<Entity> entity);
  void moveDependency(
    Identity<Entity> entity, {
    required FactorPassport from,
    required FactorPassport to,
  });
}
