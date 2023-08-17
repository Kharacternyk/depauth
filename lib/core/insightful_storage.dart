import 'package:flutter/foundation.dart';

import 'entity.dart';
import 'factor.dart';
import 'listenable_storage.dart';
import 'position.dart';
import 'storage.dart';

class InsightfulStorage extends ListenableStorage {
  final insightNotifier = _ChangeNotifier();

  final Map<Identity<Entity>, bool> _entityLoss = {};
  final Map<Identity<Factor>, bool> _factorLoss = {};
  final Map<Identity<Entity>, bool> _entityCompromise = {};
  final Map<Identity<Factor>, bool> _factorCompromise = {};
  final Map<Identity<Entity>, Set<Identity<Entity>>> _ancestors = {};
  final Map<Identity<Entity>, Set<Identity<Entity>>> _descendants = {};

  InsightfulStorage(
    super.path, {
    required super.entityDuplicatePrefix,
    required super.entityDuplicateSuffix,
  });

  Set<Identity<Entity>> getAncestors(Identity<Entity> entity) {
    switch (_ancestors[entity]) {
      case Set<Identity<Entity>> ancestors:
        return ancestors;
      case null:
        _ancestors[entity] = const {};
        final ancestors = getFactors(entity)
            .expand(getDependencies)
            .map((dependency) => dependency.identity)
            .expand((entity) => getAncestors(entity).followedBy([entity]))
            .toSet();
        _ancestors[entity] = ancestors;
        return ancestors;
    }
  }

  Set<Identity<Entity>> getDescendants(Identity<Entity> entity) {
    switch (_descendants[entity]) {
      case Set<Identity<Entity>> descendants:
        return descendants;
      case null:
        _descendants[entity] = const {};
        final descendants = getDependants(entity)
            .expand((dependant) =>
                getDescendants(dependant).followedBy([dependant]))
            .toSet();
        _descendants[entity] = descendants;
        return descendants;
    }
  }

  bool hasLostFactor(Identity<Entity> entity) {
    switch (_entityLoss[entity]) {
      case bool result:
        return result;
      case null:
        _entityLoss[entity] = false;
        final result = getFactors(entity).any(_isFactorLost);
        _entityLoss[entity] = result;
        return result;
    }
  }

  bool areAllFactorsCompromised(Identity<Entity> entity) {
    switch (_entityCompromise[entity]) {
      case bool result:
        return result;
      case null:
        _entityCompromise[entity] = false;
        final factors = getFactors(entity);
        final result =
            factors.isNotEmpty && factors.every(_isFactorCompromised);
        _entityCompromise[entity] = result;
        return result;
    }
  }

  bool _isFactorLost(Identity<Factor> factor) {
    switch (_factorLoss[factor]) {
      case bool result:
        return result;
      case null:
        final dependencies = getDependencies(factor);
        final result = dependencies.isNotEmpty &&
            dependencies.every((entity) {
              return entity.lost || hasLostFactor(entity.identity);
            });
        _factorLoss[factor] = result;
        return result;
    }
  }

  bool _isFactorCompromised(Identity<Factor> factor) {
    switch (_factorCompromise[factor]) {
      case bool result:
        return result;
      case null:
        final result = getDependencies(factor).any((dependency) {
          return dependency.compromised ||
              areAllFactorsCompromised(dependency.identity);
        });
        _factorCompromise[factor] = result;
        return result;
    }
  }

  @override
  void deleteEntity(Position position) {
    if (getEntityIdentity(position) case Identity<Entity> entity) {
      _clearCompromise(entity);
      _clearLoss(entity);
      _clearDescendantsOfAncestors(entity);
      _clearAncestorsOfDescendants(entity);
      _ancestors.remove(entity);
      _descendants.remove(entity);
      _update();
    }
    super.deleteEntity(position);
  }

  @override
  void toggleCompromised(Position position, bool value) {
    if (getEntityIdentity(position) case Identity<Entity> entity) {
      _clearCompromise(entity);
      _update();
    }
    super.toggleCompromised(position, value);
  }

  @override
  void toggleLost(Position position, bool value) {
    if (getEntityIdentity(position) case Identity<Entity> entity) {
      _clearLoss(entity);
      _update();
    }
    super.toggleLost(position, value);
  }

  @override
  void addDependency(
    Position position,
    Identity<Factor> factor,
    Identity<Entity> entity,
  ) {
    if (getEntityIdentity(position) case Identity<Entity> changedEntity) {
      _clearLoss(changedEntity);
      _clearCompromise(changedEntity);
      _clearDescendantsOfAncestors(entity);
      _descendants.remove(entity);
      _clearAncestorsOfDescendants(changedEntity);
      _ancestors.remove(changedEntity);
      _update();
    }
    super.addDependency(position, factor, entity);
  }

  @override
  void removeDependency(
    Position position,
    Identity<Factor> factor,
    Identity<Entity> entity,
  ) {
    if (getEntityIdentity(position) case Identity<Entity> changedEntity) {
      _clearLoss(changedEntity);
      _clearCompromise(changedEntity);
      _clearDescendantsOfAncestors(entity);
      _descendants.remove(entity);
      _clearAncestorsOfDescendants(changedEntity);
      _ancestors.remove(changedEntity);
      _update();
    }
    super.removeDependency(position, factor, entity);
  }

  @override
  void addFactor(Position position, Identity<Entity> entity) {
    if (getEntityIdentity(position) case Identity<Entity> entity) {
      _clearLoss(entity);
      _clearCompromise(entity);
      _update();
    }
    super.addFactor(position, entity);
  }

  @override
  void removeFactor(Position position, Identity<Factor> factor) {
    if (getEntityIdentity(position) case Identity<Entity> entity) {
      _clearLoss(entity);
      _clearCompromise(entity);
      for (final dependency in getDependencies(factor)) {
        _clearDescendantsOfAncestors(dependency.identity);
        _descendants.remove(dependency.identity);
      }
      _clearAncestorsOfDescendants(entity);
      _ancestors.remove(entity);
      _update();
    }
    super.removeFactor(position, factor);
  }

  void _clearAncestorsOfDescendants(Identity<Entity> entity) {
    for (final entity in getDescendants(entity)) {
      _ancestors.remove(entity);
    }
  }

  void _clearDescendantsOfAncestors(Identity<Entity> entity) {
    for (final entity in getAncestors(entity)) {
      _descendants.remove(entity);
    }
  }

  void _clearLoss(Identity<Entity> entity) {
    for (final entity in getDescendants(entity).followedBy([entity])) {
      _entityLoss.remove(entity);
    }
    _factorLoss.clear();
  }

  void _clearCompromise(Identity<Entity> entity) {
    for (final entity in getDescendants(entity).followedBy([entity])) {
      _entityCompromise.remove(entity);
    }
    _factorCompromise.clear();
  }

  void _update() {
    insightNotifier._update();
  }
}

class _ChangeNotifier extends ChangeNotifier {
  void _update() {
    notifyListeners();
  }
}
