import 'package:flutter/foundation.dart';

import 'entity.dart';
import 'entity_insight.dart';
import 'factor.dart';
import 'listenable_storage.dart';
import 'position.dart';
import 'storage.dart';
import 'storage_insight.dart';
import 'tertiary_set.dart';

class InsightfulStorage extends ListenableStorage {
  final entityInsightNotifier = _ChangeNotifier();
  late final storageInsight = ValueNotifier(
    StorageInsight(
      entityCount: getEntityCount(),
      lostEntityCount: _lostEntities.length,
      compromisedEntityCount: _compromisedEntities.length,
    ),
  );

  final _entityLoss = TertiarySet<Identity<Entity>>();
  final _factorLoss = TertiarySet<Identity<Factor>>();
  final _entityCompromise = TertiarySet<Identity<Entity>>();
  final _factorCompromise = TertiarySet<Identity<Factor>>();
  final _ancestors = <Identity<Entity>, Set<Identity<Entity>>>{};
  final _descendants = <Identity<Entity>, Set<Identity<Entity>>>{};

  late final _lostEntities = super.getLostEntities().toSet();
  late final _compromisedEntities = super.getCompromisedEntities().toSet();

  InsightfulStorage({
    required super.name,
    required super.path,
    required super.entityDuplicatePrefix,
    required super.entityDuplicateSuffix,
  }) {
    for (final entity in _lostEntities
        .followedBy(_compromisedEntities)
        .followedBy(getNormalEntities())) {
      _entityLoss[entity] = null;
      _entityCompromise[entity] = null;
    }
    _update();
  }

  EntityInsight getEntityInsight(Identity<Entity> entity) {
    final ancestors = _getAncestors(entity);
    final descendants = _getDescendants(entity);

    return EntityInsight(
      hasLostFactor: _entityLoss[entity] ?? false,
      areAllFactorsCompromised: _entityCompromise[entity] ?? false,
      ancestorCount: ancestors.length,
      descendantCount: descendants.length,
    );
  }

  Set<Identity<Entity>> _getAncestors(Identity<Entity> entity) {
    if (_ancestors[entity] case Set<Identity<Entity>> ancestors) {
      return ancestors;
    }

    _ancestors[entity] = const {};

    final ancestors = getFactors(entity)
        .expand(getDependencies)
        .expand((entity) => _getAncestors(entity).followedBy([entity]))
        .toSet();

    ancestors.remove(entity);

    for (final ancestor in ancestors) {
      if (_ancestors[ancestor]?.contains(entity) ?? false) {
        _ancestors[ancestor]
          ?..addAll(ancestors)
          ..remove(ancestor);
      }
    }

    _ancestors[entity] = ancestors;

    return ancestors;
  }

  Set<Identity<Entity>> _getDescendants(Identity<Entity> entity) {
    if (_descendants[entity] case Set<Identity<Entity>> descendants) {
      return descendants;
    }

    _descendants[entity] = const {};

    final descendants = getDependants(entity)
        .expand(
            (dependant) => _getDescendants(dependant).followedBy([dependant]))
        .toSet();

    descendants.remove(entity);

    for (final descendant in descendants) {
      if (_descendants[descendant]?.contains(entity) ?? false) {
        _descendants[descendant]
          ?..addAll(descendants)
          ..remove(descendant);
      }
    }

    _descendants[entity] = descendants;
    return descendants;
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
        storageInsight.value = storageInsight.value.add(lost: 1);
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
        storageInsight.value = storageInsight.value.add(compromised: 1);
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
  deleteEntity(position) {
    _getEntity(position, (entity) {
      storageInsight.value = storageInsight.value.add(all: -1);
      _clearLoss(entity);
      _clearCompromise(entity);
      _clearCoupling(upward: [entity], downward: [entity]);

      if (_lostEntities.remove(entity)) {
        storageInsight.value = storageInsight.value.add(lost: -1);
      }

      if (_compromisedEntities.remove(entity)) {
        storageInsight.value = storageInsight.value.add(compromised: -1);
      }

      _entityLoss.forget(entity);
      _entityCompromise.forget(entity);
    });
    super.deleteEntity(position);
    _update();
  }

  @override
  toggleCompromised(position, value) {
    _getEntity(position, (entity) {
      if (_entityCompromise[entity] == false &&
          value != _compromisedEntities.contains(entity)) {
        storageInsight.value = storageInsight.value.add(
          compromised: value ? 1 : -1,
        );
      }

      if (value) {
        _compromisedEntities.add(entity);
      } else {
        _compromisedEntities.remove(entity);
      }

      _clearCompromise(entity);
    });
    super.toggleCompromised(position, value);
    _update();
  }

  @override
  toggleLost(position, value) {
    _getEntity(position, (entity) {
      if (_entityLoss[entity] == false &&
          value != _lostEntities.contains(entity)) {
        storageInsight.value = storageInsight.value.add(
          lost: value ? 1 : -1,
        );
      }

      if (value) {
        _lostEntities.add(entity);
      } else {
        _lostEntities.remove(entity);
      }

      _clearLoss(entity);
    });
    super.toggleLost(position, value);
    _update();
  }

  @override
  addDependencyAsFactor(position, {required entity, required dependency}) {
    _clearLoss(entity);
    _clearCompromise(entity);
    _clearCoupling(upward: [dependency], downward: [entity]);
    super.addDependencyAsFactor(
      position,
      entity: entity,
      dependency: dependency,
    );
    _update();
  }

  @override
  addDependency(position, factor, entity) {
    _getEntity(position, (changedEntity) {
      _clearLoss(changedEntity);
      _clearCompromise(changedEntity);
      _clearCoupling(upward: [entity], downward: [changedEntity]);
    });
    super.addDependency(position, factor, entity);
    _update();
  }

  @override
  removeDependency(position, factor, entity) {
    _getEntity(position, (changedEntity) {
      _clearLoss(changedEntity);
      _clearCompromise(changedEntity);
      _clearCoupling(upward: [entity], downward: [changedEntity]);
    });
    super.removeDependency(position, factor, entity);
    _update();
  }

  @override
  addFactor(position, entity) {
    _getEntity(position, (entity) {
      _clearLoss(entity);
      _clearCompromise(entity);
    });
    super.addFactor(position, entity);
    _update();
  }

  @override
  removeFactor(position, factor) {
    _getEntity(position, (entity) {
      _clearLoss(entity);
      _clearCompromise(entity);
      _clearCoupling(
        upward: getDependencies(factor),
        downward: [entity],
      );
    });
    super.removeFactor(position, factor);
    _update();
  }

  @override
  resetLoss() {
    super.resetLoss();
    _entityLoss.makeAll(false);
    _factorLoss.makeAll(false);
    _lostEntities.clear();

    storageInsight.value = StorageInsight(
      entityCount: storageInsight.value.entityCount,
      lostEntityCount: 0,
      compromisedEntityCount: storageInsight.value.compromisedEntityCount,
    );

    _update();
  }

  @override
  resetCompromise() {
    super.resetCompromise();
    _entityCompromise.makeAll(false);
    _factorCompromise.makeAll(false);
    _compromisedEntities.clear();

    storageInsight.value = StorageInsight(
      entityCount: storageInsight.value.entityCount,
      lostEntityCount: storageInsight.value.lostEntityCount,
      compromisedEntityCount: 0,
    );

    _update();
  }

  @override
  createEntity(position, name) {
    super.createEntity(position, name);
    _getEntity(position, (entity) {
      _entityLoss[entity] = null;
      _entityCompromise[entity] = null;
    });
    storageInsight.value = storageInsight.value.add(all: 1);
    _update();
  }

  @override
  getLostEntities() => _lostEntities;

  @override
  getCompromisedEntities() => _compromisedEntities;

  void _getEntity(Position position, void Function(Identity<Entity>) callback) {
    if (getEntityIdentity(position) case Identity<Entity> entity) {
      callback(entity);
    }
  }

  void _clearCoupling({
    required Iterable<Identity<Entity>> upward,
    required Iterable<Identity<Entity>> downward,
  }) {
    final expandedUpward =
        upward.followedBy(upward.expand(_getAncestors).toList());
    final expandedDownward =
        downward.followedBy(downward.expand(_getDescendants).toList());

    expandedUpward.forEach(_descendants.remove);
    expandedDownward.forEach(_ancestors.remove);
  }

  void _clearLoss(Identity<Entity> entity) {
    for (final entity in _getDescendants(entity).followedBy([entity])) {
      if (_entityLoss[entity] == true && !_lostEntities.contains(entity)) {
        storageInsight.value = storageInsight.value.add(lost: -1);
      }
      _entityLoss[entity] = null;
    }
    _factorLoss.clear();
  }

  void _clearCompromise(Identity<Entity> entity) {
    for (final entity in _getDescendants(entity).followedBy([entity])) {
      if (_entityCompromise[entity] == true &&
          !_compromisedEntities.contains(entity)) {
        storageInsight.value = storageInsight.value.add(compromised: -1);
      }
      _entityCompromise[entity] = null;
    }
    _factorCompromise.clear();
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
