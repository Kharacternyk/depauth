import 'dart:math';

import 'package:flutter/foundation.dart';

import 'entity.dart';
import 'entity_insight.dart';
import 'flattened_storage.dart';
import 'listenable_map.dart';
import 'storage.dart';
import 'storage_insight.dart';
import 'trait.dart';

class InsightfulStorage extends FlattenedStorage {
  final entityInsightNotifier = _ChangeNotifier();
  late final storageInsight = ValueNotifier(const StorageInsight.zero());

  late var _entityCount = super.entityCount;
  var _lostEntityCount = 0;
  var _compromisedEntityCount = 0;

  late final _entityLoss = ListenableMap<Identity<Entity>, Trait>(
    onSet: (entity, map) {
      ++_lostEntityCount;

      for (final dependant in getDependants(entity)) {
        if (map[dependant] == null) {
          map[dependant] = _getEntityLoss(dependant);
        }
      }
    },
    onUnset: (entity, map) {
      --_lostEntityCount;

      for (final dependant in getDependants(entity)) {
        if (map[dependant] is InheritedTrait) {
          map[dependant] = _getEntityLoss(dependant);
        }
      }
    },
  );
  late final _entityCompromise = ListenableMap<Identity<Entity>, Trait>(
    onSet: (entity, map) {
      ++_compromisedEntityCount;

      for (final dependant in getDependants(entity)) {
        if (map[dependant] == null) {
          map[dependant] = _getEntityCompromise(dependant);
        }
      }
    },
    onUnset: (entity, map) {
      --_compromisedEntityCount;

      for (final dependant in getDependants(entity)) {
        if (map[dependant] is InheritedTrait) {
          map[dependant] = _getEntityCompromise(dependant);
        }
      }
    },
  );
  final _bubbledImportance = <Identity<Entity>, int>{};

  InsightfulStorage({
    required super.name,
    required super.path,
    required super.entityDuplicatePrefix,
    required super.entityDuplicateSuffix,
  }) {
    for (final entity in lostEntities) {
      _entityLoss[entity] = const OwnTrait();
    }
    for (final entity in compromisedEntities) {
      _entityCompromise[entity] = const OwnTrait();
    }

    _update();
  }

  EntityInsight getEntityInsight(Identity<Entity> entity) {
    return EntityInsight(
      loss: _entityLoss[entity],
      compromise: _entityCompromise[entity],
      ancestorCount: getAncestors(entity).length,
      descendantCount: getDescendants(entity).length,
      bubbledImportance: _getBubbledImportance(entity),
    );
  }

  int _getBubbledImportance(Identity<Entity> entity) {
    if (_bubbledImportance[entity] case int value) {
      return value;
    }

    final closure = getClosure(entity);
    var outerValue = 0;
    var innerValue = 0;
    var secondInnerValue = 0;
    Identity<Entity>? innerLeader;

    for (final entity in closure) {
      for (final (dependant, importance)
          in getDependantsWithImportance(entity)) {
        if (closure.contains(dependant)) {
          if (importance > innerValue) {
            secondInnerValue = innerValue;
            innerValue = importance;
            innerLeader = dependant;
          } else if (importance == innerValue && innerLeader != dependant) {
            innerLeader = null;
          } else if (importance > secondInnerValue) {
            secondInnerValue = importance;
          }
        } else {
          outerValue = max(
            outerValue,
            max(importance, _getBubbledImportance(dependant)),
          );
        }
      }
    }

    if (outerValue >= innerValue) {
      for (final entity in closure) {
        _bubbledImportance[entity] = outerValue;
      }

      return outerValue;
    } else {
      for (final entity in closure) {
        if (entity == innerLeader) {
          _bubbledImportance[entity] = secondInnerValue;
        } else {
          _bubbledImportance[entity] = innerValue;
        }
      }

      return entity == innerLeader ? secondInnerValue : innerValue;
    }
  }

  InheritedTrait? _getEntityLoss(
    Identity<Entity> entity, [
    Set<Identity<Entity>> seen = const {},
  ]) {
    final seenWithThis = seen.union({entity});
    final lostFactor = getFactors(entity).map(getDependencies).where((factor) {
      return factor.every((dependency) {
        return _hasTrait(
          entity: dependency,
          seen: seenWithThis,
          map: _entityLoss,
          recurse: _getEntityLoss,
        );
      });
    }).firstOrNull;

    if (lostFactor != null) {
      return InheritedTrait(lostFactor);
    }

    return null;
  }

  InheritedTrait? _getEntityCompromise(
    Identity<Entity> entity, [
    Set<Identity<Entity>> seen = const {},
  ]) {
    final seenWithThis = seen.union({entity});
    final compromisedDependencies = <Identity<Entity>>{};
    final factors = getFactors(entity).map(getDependencies).where((factor) {
      return factor.isNotEmpty;
    });

    for (final factor in factors) {
      final compromisedDependency = factor.where((dependency) {
        return _hasTrait(
          entity: dependency,
          seen: seenWithThis,
          map: _entityCompromise,
          recurse: _getEntityCompromise,
        );
      }).firstOrNull;

      if (compromisedDependency == null) {
        return null;
      } else {
        compromisedDependencies.add(compromisedDependency);
      }
    }

    return compromisedDependencies.isNotEmpty
        ? InheritedTrait(compromisedDependencies)
        : null;
  }

  @override
  deleteEntity(entity) {
    final dependants = getDependants(entity.identity);

    --_entityCount;
    _clearImportance(entity.identity);

    super.deleteEntity(entity);

    _entityLoss[entity.identity] = null;
    _entityCompromise[entity.identity] = null;

    dependants.forEach(_updateTraits);
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
    _entityCompromise[entity.identity] =
        value ? const OwnTrait() : _getEntityCompromise(entity.identity);
    super.toggleCompromised(entity, value);
    _update();
  }

  @override
  toggleLost(entity, value) {
    _entityLoss[entity.identity] =
        value ? const OwnTrait() : _getEntityLoss(entity.identity);
    super.toggleLost(entity, value);
    _update();
  }

  @override
  addDependencyAsFactor(entity, dependency) {
    super.addDependencyAsFactor(entity, dependency);
    _clearImportance(entity.identity);
    _updateTraits(entity.identity);
    _update();
  }

  @override
  addDependency(factor, entity) {
    super.addDependency(factor, entity);
    _clearImportance(factor.entity.identity);
    _updateTraits(factor.entity.identity);
    _update();
  }

  @override
  removeDependency(dependency) {
    final identity = dependency.factor.entity.identity;
    _clearImportance(identity);
    super.removeDependency(dependency);
    _updateTraits(identity);
    _update();
  }

  @override
  moveDependency(dependency, factor) {
    final identities = {
      dependency.factor.entity.identity,
      factor.entity.identity,
    };
    identities.forEach(_clearImportance);
    super.moveDependency(dependency, factor);
    identities.forEach(_updateTraits);
    _update();
  }

  @override
  moveDependencyAsFactor(dependency, entity) {
    final identities = {dependency.factor.entity.identity, entity.identity};
    identities.forEach(_clearImportance);
    super.moveDependencyAsFactor(dependency, entity);
    identities.forEach(_updateTraits);
    _update();
  }

  @override
  mergeFactors(into, from) {
    final identities = {into.entity.identity, from.entity.identity};
    identities.forEach(_clearImportance);
    super.mergeFactors(into, from);
    identities.forEach(_updateTraits);
    _update();
  }

  @override
  removeFactor(factor) {
    _clearImportance(factor.entity.identity);
    super.removeFactor(factor);
    _updateTraits(factor.entity.identity);
    _update();
  }

  @override
  resetLoss() {
    super.resetLoss();
    _entityLoss.clear();
    _lostEntityCount = 0;
    _update();
  }

  @override
  resetCompromise() {
    super.resetCompromise();
    _entityCompromise.clear();
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
  int get entityCount => _entityCount;

  bool _hasTrait({
    required Identity<Entity> entity,
    required Set<Identity<Entity>> seen,
    required ListenableMap<Identity<Entity>, Trait> map,
    required InheritedTrait? Function(Identity<Entity>, Set<Identity<Entity>>)
        recurse,
  }) {
    if (seen.contains(entity)) {
      return false;
    }

    final trait = map[entity];

    if (trait is OwnTrait) {
      return true;
    }
    if (getDescendants(seen.first).contains(entity)) {
      return recurse(entity, seen) != null;
    }

    return trait != null;
  }

  void _updateTraits(Identity<Entity> entity) {
    if (_entityLoss[entity] is! OwnTrait) {
      _entityLoss[entity] = _getEntityLoss(entity);
    }
    if (_entityCompromise[entity] is! OwnTrait) {
      _entityCompromise[entity] = _getEntityCompromise(entity);
    }
  }

  void _clearImportance(Identity<Entity> entity) {
    getAncestors(entity)
        .followedBy([entity]).forEach(_bubbledImportance.remove);
  }

  void _update() {
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
