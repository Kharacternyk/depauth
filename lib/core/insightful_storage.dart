import 'dart:math';

import 'package:flutter/foundation.dart';

import 'entity.dart';
import 'entity_insight.dart';
import 'factor.dart';
import 'flattened_storage.dart';
import 'storage.dart';
import 'storage_insight.dart';
import 'tertiary_set.dart';

class InsightfulStorage extends FlattenedStorage {
  final entityInsightNotifier = _ChangeNotifier();
  late final storageInsight = ValueNotifier(
    StorageInsight(
      entityCount: _entityCount,
      lostEntityCount: _lostEntityCount,
      compromisedEntityCount: _compromisedEntityCount,
    ),
  );

  late var _entityCount = super.entityCount;
  late var _lostEntityCount = _lostEntities.length;
  late var _compromisedEntityCount = _compromisedEntities.length;

  final _entityLoss = TertiarySet<Identity<Entity>>();
  final _factorLoss = TertiarySet<Identity<Factor>>();
  final _entityCompromise = TertiarySet<Identity<Entity>>();
  final _factorCompromise = TertiarySet<Identity<Factor>>();

  late final _lostEntities = super.lostEntities.toSet();
  late final _compromisedEntities = super.compromisedEntities.toSet();

  final _bubbledImportance = <Identity<Entity>, int>{};

  InsightfulStorage({
    required super.name,
    required super.path,
    required super.entityDuplicatePrefix,
    required super.entityDuplicateSuffix,
  }) {
    for (final entity in _lostEntities
        .followedBy(_compromisedEntities)
        .followedBy(normalEntities)) {
      _entityLoss[entity] = null;
      _entityCompromise[entity] = null;
    }
    _update();
  }

  EntityInsight getEntityInsight(Identity<Entity> entity) {
    return EntityInsight(
      hasLostFactor: _entityLoss[entity] ?? false,
      areAllFactorsCompromised: _entityCompromise[entity] ?? false,
      ancestorCount: getAncestors(entity).length,
      descendantCount: getDescendants(entity).length,
      bubbledImportance: _getBubbledImportance(entity, const {}).value,
    );
  }

  ({int value, bool isCacheable}) _getBubbledImportance(
    Identity<Entity> entity,
    Set<Identity<Entity>> seen,
  ) {
    if (_bubbledImportance[entity] case int value) {
      return (value: value, isCacheable: true);
    }

    final seenWithThis = seen.union({entity});
    var value = 0;
    var isCacheable = true;

    for (final (dependant, importance) in getDependantsWithImportance(entity)) {
      if (seenWithThis.contains(dependant)) {
        isCacheable = false;
        continue;
      }

      final dependantImportance =
          _getBubbledImportance(dependant, seenWithThis);

      if (!dependantImportance.isCacheable) {
        isCacheable = false;
      }
      if (max(dependantImportance.value, importance) == 0) {
        continue;
      }

      final factors = getFactors(dependant);
      final dependencies = factors.expand((factor) {
        return getDependencies(factor).map((dependency) {
          return (factor, dependency);
        });
      });
      final otherDependencies = <Identity<Entity>, List<Identity<Factor>>>{};
      final dependantFactors = <Identity<Factor>>[];

      for (final (factor, dependency) in dependencies) {
        if (seenWithThis.contains(dependency)) {
          dependantFactors.add(factor);
          continue;
        }

        final factors = otherDependencies[dependency];

        if (factors != null) {
          factors.add(factor);
        } else {
          otherDependencies[dependency] = [factor];
        }
      }

      final sortedDependencies = otherDependencies.entries.toList();

      sortedDependencies.sort((first, second) {
        return second.value.length.compareTo(first.value.length);
      });

      final unlockedFactors = dependantFactors.toSet();
      var requiredOtherDependencyCount = 0;

      while (unlockedFactors.length < factors.length &&
          requiredOtherDependencyCount < sortedDependencies.length) {
        final entry = sortedDependencies[requiredOtherDependencyCount];

        unlockedFactors.addAll(entry.value);
        ++requiredOtherDependencyCount;
      }

      value = max(
        value,
        max(importance, dependantImportance.value) ~/
            (requiredOtherDependencyCount + 1),
      );
    }

    if (isCacheable || seen.isEmpty) {
      _bubbledImportance[entity] = value;
    }

    return (value: value, isCacheable: isCacheable);
  }

  bool _hasLostFactor(Identity<Entity> entity, Set<Identity<Entity>> seen) {
    if (_entityLoss[entity] case bool result) {
      return result;
    }

    final seenWithThis = seen.union({entity});
    var hasLostFactor = false;
    var isCacheable = true;

    for (final factor in getFactors(entity)) {
      final lost = _isFactorLost(factor, seenWithThis);

      if (lost ?? false) {
        hasLostFactor = true;
        isCacheable = true;
        break;
      } else if (lost == null) {
        isCacheable = false;
      }
    }

    if (seen.isEmpty || isCacheable) {
      _entityLoss[entity] = hasLostFactor;

      if (hasLostFactor && !_lostEntities.contains(entity)) {
        ++_lostEntityCount;
      }
    }

    return hasLostFactor;
  }

  bool _areAllFactorsCompromised(
    Identity<Entity> entity,
    Set<Identity<Entity>> seen,
  ) {
    if (_entityCompromise[entity] case bool result) {
      return result;
    }

    final seenWithThis = seen.union({entity});
    final factors = getFactors(entity);

    if (factors.isEmpty) {
      _entityCompromise[entity] = false;

      return false;
    }

    var areAllFactorsCompromised = true;
    var isCacheable = true;

    for (final factor in factors) {
      final compromised = _isFactorCompromised(factor, seenWithThis);

      if (compromised == false) {
        areAllFactorsCompromised = false;
        isCacheable = true;
        break;
      } else if (compromised == null) {
        areAllFactorsCompromised = false;
        isCacheable = false;
      }
    }

    if (seen.isEmpty || isCacheable) {
      _entityCompromise[entity] = areAllFactorsCompromised;

      if (areAllFactorsCompromised && !_compromisedEntities.contains(entity)) {
        ++_compromisedEntityCount;
      }
    }

    return areAllFactorsCompromised;
  }

  bool? _isFactorLost(Identity<Factor> factor, Set<Identity<Entity>> seen) {
    if (_factorLoss[factor] case bool result) {
      return result;
    }

    final dependencies = getDependencies(factor);

    if (dependencies.isEmpty) {
      _factorLoss[factor] = false;

      return false;
    }

    bool? result = true;

    for (final dependency in dependencies) {
      if (seen.contains(dependency)) {
        result = null;
      } else if (!_lostEntities.contains(dependency) &&
          !_hasLostFactor(dependency, seen)) {
        result = false;
        break;
      }
    }

    if (result case bool result) {
      _factorLoss[factor] = result;
    }

    return result;
  }

  bool? _isFactorCompromised(
    Identity<Factor> factor,
    Set<Identity<Entity>> seen,
  ) {
    if (_factorCompromise[factor] case bool result) {
      return result;
    }
    final dependencies = getDependencies(factor);

    bool? result = false;

    for (final dependency in dependencies) {
      if (seen.contains(dependency)) {
        result = null;
      } else if (_compromisedEntities.contains(dependency) ||
          _areAllFactorsCompromised(dependency, seen)) {
        result = true;
      }
    }

    if (result case bool result) {
      _factorCompromise[factor] = result;
    }

    return result;
  }

  @override
  deleteEntity(entity) {
    --_entityCount;
    _clearLoss(entity.identity);
    _clearCompromise(entity.identity);
    _clearImportance(entity.identity);

    if (_lostEntities.remove(entity.identity)) {
      --_lostEntityCount;
    }

    if (_compromisedEntities.remove(entity.identity)) {
      --_compromisedEntityCount;
    }

    _entityLoss.forget(entity.identity);
    _entityCompromise.forget(entity.identity);

    final dependants = getDependants(entity.identity);

    super.deleteEntity(entity);

    dependants.forEach(_clearImportance);

    _update();
  }

  @override
  changeImportance(entity, value) {
    _clearImportance(entity.identity);
    super.changeImportance(entity, value);
    _update();
  }

  @override
  toggleCompromised(entity, value) {
    if (_entityCompromise[entity.identity] == false &&
        value != _compromisedEntities.contains(entity.identity)) {
      if (value) {
        ++_compromisedEntityCount;
      } else {
        --_compromisedEntityCount;
      }
    }

    if (value) {
      _compromisedEntities.add(entity.identity);
    } else {
      _compromisedEntities.remove(entity.identity);
    }

    _clearCompromise(entity.identity);

    super.toggleCompromised(entity, value);

    _update();
  }

  @override
  toggleLost(entity, value) {
    if (_entityLoss[entity.identity] == false &&
        value != _lostEntities.contains(entity.identity)) {
      if (value) {
        ++_lostEntityCount;
      } else {
        --_lostEntityCount;
      }
    }

    if (value) {
      _lostEntities.add(entity.identity);
    } else {
      _lostEntities.remove(entity.identity);
    }

    _clearLoss(entity.identity);

    super.toggleLost(entity, value);

    _update();
  }

  @override
  addDependencyAsFactor(entity, dependency) {
    _clearLoss(entity.identity);
    _clearCompromise(entity.identity);
    super.addDependencyAsFactor(entity, dependency);
    _clearImportance(entity.identity);
    _update();
  }

  @override
  addDependency(factor, entity) {
    _clearLoss(factor.entity.identity);
    _clearCompromise(factor.entity.identity);
    super.addDependency(factor, entity);
    _clearImportance(factor.entity.identity);
    _update();
  }

  @override
  removeDependency(dependency) {
    final identity = dependency.factor.entity.identity;
    _clearLoss(identity);
    _clearCompromise(identity);
    _clearImportance(identity);
    super.removeDependency(dependency);
    _update();
  }

  @override
  moveDependency(dependency, factor) {
    for (final identity in {
      dependency.factor.entity.identity,
      factor.entity.identity
    }) {
      _clearLoss(identity);
      _clearCompromise(identity);
      _clearImportance(identity);
    }
    super.moveDependency(dependency, factor);
    _update();
  }

  @override
  moveDependencyAsFactor(dependency, entity) {
    for (final identity in {
      dependency.factor.entity.identity,
      entity.identity
    }) {
      _clearLoss(identity);
      _clearCompromise(identity);
      _clearImportance(identity);
    }
    super.moveDependencyAsFactor(dependency, entity);
    _update();
  }

  @override
  addFactor(entity) {
    _clearLoss(entity.identity);
    _clearCompromise(entity.identity);
    super.addFactor(entity);
    _update();
  }

  @override
  mergeFactors(into, from) {
    for (final identity in {into.entity.identity, from.entity.identity}) {
      _clearLoss(identity);
      _clearCompromise(identity);
      _clearImportance(identity);
    }
    super.mergeFactors(into, from);
    _update();
  }

  @override
  removeFactor(factor) {
    _clearLoss(factor.entity.identity);
    _clearCompromise(factor.entity.identity);
    _clearImportance(factor.entity.identity);
    super.removeFactor(factor);
    _update();
  }

  @override
  resetLoss() {
    super.resetLoss();
    _entityLoss.makeAll(false);
    _factorLoss.makeAll(false);
    _lostEntities.clear();
    _lostEntityCount = 0;
    _update();
  }

  @override
  resetCompromise() {
    super.resetCompromise();
    _entityCompromise.makeAll(false);
    _factorCompromise.makeAll(false);
    _compromisedEntities.clear();
    _compromisedEntityCount = 0;
    _update();
  }

  @override
  createEntity(position, name) {
    super.createEntity(position, name);
    ++_entityCount;
    _update();
  }

  @override
  Iterable<Identity<Entity>> get lostEntities => _lostEntities;

  @override
  Iterable<Identity<Entity>> get compromisedEntities => _compromisedEntities;

  @override
  int get entityCount => _entityCount;

  void _clearLoss(Identity<Entity> entity) {
    for (final entity in getDescendants(entity).followedBy([entity])) {
      if (_entityLoss[entity] == true && !_lostEntities.contains(entity)) {
        --_lostEntityCount;
      }
      _entityLoss[entity] = null;
    }
    _factorLoss.clear();
  }

  void _clearCompromise(Identity<Entity> entity) {
    for (final entity in getDescendants(entity).followedBy([entity])) {
      if (_entityCompromise[entity] == true &&
          !_compromisedEntities.contains(entity)) {
        --_compromisedEntityCount;
      }
      _entityCompromise[entity] = null;
    }
    _factorCompromise.clear();
  }

  void _clearImportance(Identity<Entity> entity) {
    getAncestors(entity)
        .followedBy([entity]).forEach(_bubbledImportance.remove);
  }

  void _update() {
    for (var entity = _entityLoss.getRandom(null);
        entity != null;
        entity = _entityLoss.getRandom(null)) {
      _entityLoss[entity] = _hasLostFactor(entity, const {});
    }

    for (var entity = _entityCompromise.getRandom(null);
        entity != null;
        entity = _entityCompromise.getRandom(null)) {
      _entityCompromise[entity] = _areAllFactorsCompromised(entity, const {});
    }

    storageInsight.value = StorageInsight(
      entityCount: _entityCount,
      lostEntityCount: _lostEntityCount,
      compromisedEntityCount: _compromisedEntityCount,
    );

    entityInsightNotifier._update();
  }

  @override
  dispose() {
    entityInsightNotifier.dispose();
    storageInsight.dispose();
    super.dispose();
  }
}

class _ChangeNotifier extends ChangeNotifier {
  void _update() {
    notifyListeners();
  }
}
