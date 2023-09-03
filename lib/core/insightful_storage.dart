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
      hasLostEntities: _lostPositions.isNotEmpty,
      hasCompromisedEntities: _compromisedPositions.isNotEmpty,
    ),
  );

  final _entityLoss = TertiarySet<Identity<Entity>>();
  final _factorLoss = TertiarySet<Identity<Factor>>();
  final _entityCompromise = TertiarySet<Identity<Entity>>();
  final _factorCompromise = TertiarySet<Identity<Factor>>();
  final _ancestors = <Identity<Entity>, Set<Identity<Entity>>>{};
  final _descendants = <Identity<Entity>, Set<Identity<Entity>>>{};

  late final _lostPositions = super.getLostPositions().toSet();
  late final _compromisedPositions = super.getCompromisedPositions().toSet();

  InsightfulStorage(
    super.path, {
    required super.entityDuplicatePrefix,
    required super.entityDuplicateSuffix,
  });

  EntityInsight getEntityInsight(Identity<Entity> entity) {
    final ancestors = _getAncestors(entity);
    final descendants = _getDescendants(entity);

    return EntityInsight(
      hasLostFactor: _hasLostFactor(entity, const {}),
      areAllFactorsCompromised: _areAllFactorsCompromised(entity, const {}),
      ancestorCount: ancestors.length,
      descendantCount: descendants.length,
      coupling: (ancestors.length +
              descendants.length -
              ancestors.intersection(descendants).length) /
          (storageInsight.value.entityCount > 1
              ? storageInsight.value.entityCount - 1
              : 1),
    );
  }

  Set<Identity<Entity>> _getAncestors(Identity<Entity> entity) {
    if (_ancestors[entity] case Set<Identity<Entity>> ancestors) {
      return ancestors;
    }

    _ancestors[entity] = const {};

    final ancestors = getFactors(entity)
        .expand(getDependencies)
        .map((dependency) => dependency.identity)
        .expand((entity) => _getAncestors(entity).followedBy([entity]))
        .toSet();

    ancestors.remove(entity);

    for (final ancestor in ancestors) {
      if (_ancestors[ancestor]?.contains(entity) == true) {
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
      if (_descendants[descendant]?.contains(entity) == true) {
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

      if (lost == true) {
        hasLostFactor = true;
        isCacheable = true;
        break;
      } else if (lost == null) {
        isCacheable = false;
      }
    }

    if (seen.isEmpty || isCacheable) {
      _entityLoss[entity] = hasLostFactor;
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
      if (seen.contains(dependency.identity)) {
        result = null;
      } else if (!dependency.lost &&
          !_hasLostFactor(dependency.identity, seen)) {
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
      if (seen.contains(dependency.identity)) {
        result = null;
      } else if (dependency.compromised ||
          _areAllFactorsCompromised(dependency.identity, seen)) {
        result = true;
      }
    }

    if (result case bool result) {
      _factorCompromise[factor] = result;
    }

    return result;
  }

  @override
  void deleteEntity(Position position) {
    _getEntity(position, (entity) {
      _clearCompromise(entity);
      _clearLoss(entity);
      _clearCoupling(upward: [entity], downward: [entity]);
    });
    super.deleteEntity(position);
    storageInsight.value = storageInsight.value.decrement();
    _update();
  }

  @override
  void toggleCompromised(Position position, bool value) {
    _getEntity(position, (entity) {
      _clearCompromise(entity, includingSelf: false);
    });

    super.toggleCompromised(position, value);

    if (value) {
      _compromisedPositions.add(position);
    } else {
      _compromisedPositions.remove(position);
    }

    storageInsight.value = StorageInsight(
      entityCount: storageInsight.value.entityCount,
      hasLostEntities: storageInsight.value.hasLostEntities,
      hasCompromisedEntities: _compromisedPositions.isNotEmpty,
    );

    _update();
  }

  @override
  void toggleLost(Position position, bool value) {
    _getEntity(position, (entity) {
      _clearLoss(entity, includingSelf: false);
    });

    super.toggleLost(position, value);

    if (value) {
      _lostPositions.add(position);
    } else {
      _lostPositions.remove(position);
    }

    storageInsight.value = StorageInsight(
      entityCount: storageInsight.value.entityCount,
      hasLostEntities: _lostPositions.isNotEmpty,
      hasCompromisedEntities: storageInsight.value.hasCompromisedEntities,
    );

    _update();
  }

  @override
  void addDependencyAsFactor(
    Position position, {
    required Identity<Entity> entity,
    required Identity<Entity> dependency,
  }) {
    _clearLoss(entity);
    _clearCompromise(entity);
    _clearCoupling(upward: [dependency], downward: [entity]);
    super.addDependencyAsFactor(
      position,
      entity: entity,
      dependency: dependency,
    );
  }

  @override
  void addDependency(
    Position position,
    Identity<Factor> factor,
    Identity<Entity> entity,
  ) {
    _getEntity(position, (changedEntity) {
      _clearLoss(changedEntity);
      _clearCompromise(changedEntity);
      _clearCoupling(upward: [entity], downward: [changedEntity]);
    });
    super.addDependency(position, factor, entity);
    _update();
  }

  @override
  void removeDependency(
    Position position,
    Identity<Factor> factor,
    Identity<Entity> entity,
  ) {
    _getEntity(position, (changedEntity) {
      _clearLoss(changedEntity);
      _clearCompromise(changedEntity);
      _clearCoupling(upward: [entity], downward: [changedEntity]);
    });
    super.removeDependency(position, factor, entity);
    _update();
  }

  @override
  void addFactor(Position position, Identity<Entity> entity) {
    _getEntity(position, (entity) {
      _clearLoss(entity);
      _clearCompromise(entity);
    });
    super.addFactor(position, entity);
    _update();
  }

  @override
  void removeFactor(Position position, Identity<Factor> factor) {
    _getEntity(position, (entity) {
      _clearLoss(entity);
      _clearCompromise(entity);
      _clearCoupling(
        upward: getDependencies(factor).map((entity) => entity.identity),
        downward: [entity],
      );
    });
    super.removeFactor(position, factor);
    _update();
  }

  @override
  void resetLoss() {
    super.resetLoss();
    _entityLoss.makeAllFalse();
    _factorLoss.makeAllFalse();
    _lostPositions.clear();

    storageInsight.value = StorageInsight(
      entityCount: storageInsight.value.entityCount,
      hasLostEntities: false,
      hasCompromisedEntities: storageInsight.value.hasCompromisedEntities,
    );

    _update();
  }

  @override
  void resetCompromise() {
    super.resetCompromise();
    _entityCompromise.makeAllFalse();
    _factorCompromise.makeAllFalse();
    _compromisedPositions.clear();

    storageInsight.value = StorageInsight(
      entityCount: storageInsight.value.entityCount,
      hasLostEntities: storageInsight.value.hasLostEntities,
      hasCompromisedEntities: false,
    );

    _update();
  }

  @override
  void createEntity(Position position, String name) {
    super.createEntity(position, name);
    storageInsight.value = storageInsight.value.increment();
    _update();
  }

  @override
  getLostPositions() {
    return _lostPositions;
  }

  @override
  getCompromisedPositions() {
    return _compromisedPositions;
  }

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

  void _clearLoss(Identity<Entity> entity, {bool includingSelf = true}) {
    for (final entity
        in _getDescendants(entity).followedBy([if (includingSelf) entity])) {
      _entityLoss[entity] = null;
    }
    _factorLoss.clear();
  }

  void _clearCompromise(Identity<Entity> entity, {bool includingSelf = true}) {
    for (final entity
        in _getDescendants(entity).followedBy([if (includingSelf) entity])) {
      _entityCompromise[entity] = null;
    }
    _factorCompromise.clear();
  }

  void _update() {
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
