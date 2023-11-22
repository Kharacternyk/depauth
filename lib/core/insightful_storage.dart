import 'package:flutter/foundation.dart';

import 'access_map.dart';
import 'entity.dart';
import 'entity_insight.dart';
import 'entity_insight_origin.dart';
import 'importance_map.dart';
import 'listenable_storage.dart';
import 'storage.dart';
import 'storage_insight.dart';

class InsightfulStorage extends ListenableStorage
    implements EntityInsightOrigin {
  final _entityInsightNotifier = _ChangeNotifier();
  late final storageInsight = ValueNotifier(const StorageInsight.zero());
  late final _notedEntities = super.notedEntities.toSet();
  late var _entityCount = super.entityCount;

  InsightfulStorage({
    required super.path,
    required super.entityDuplicatePrefix,
    required super.entityDuplicateSuffix,
  }) {
    _reachability.initialize(origins: originEntities, blocks: lostEntities);
    _compromise.initialize(origins: compromisedEntities);
    _importance.setAll(positiveImportance);
    _update();
  }

  @override
  ChangeNotifier get entityInsightNotifier => _entityInsightNotifier;

  @override
  getEntityInsight(entity) {
    return EntityInsight(
      reachability: _reachability[entity],
      compromise: _compromise[entity],
      dependencyCount: getDistinctDependencies(entity).length,
      dependantCount: getDependants(entity).length,
      importance: _importance[entity],
    );
  }

  final _dependencies = <Identity<Entity>, Set<Identity<Entity>>>{};
  final _dependants = <Identity<Entity>, Set<Identity<Entity>>>{};
  late final _reachability = AccessMap(getDependants, _derive);
  late final _compromise = AccessMap(getDependants, _derive);
  late final _importance = ImportanceMap(
    getDependants: getDependants,
    getDependencies: getDistinctDependencies,
  );

  Iterable<Identity<Entity>> _derive(
    Identity<Entity> entity,
    bool Function(Identity<Entity>) isReachable,
  ) {
    final reachableDependencies = <Identity<Entity>>{};

    for (final factor in getFactors(entity)) {
      final dependencies = getDependencies(factor.identity);

      if (dependencies.length < factor.threshold) {
        return const Iterable.empty();
      }

      var count = 0;

      for (final reachableDependency in dependencies.where(isReachable)) {
        reachableDependencies.add(reachableDependency);
        ++count;

        if (count >= factor.threshold) {
          break;
        }
      }

      if (count < factor.threshold) {
        return const Iterable.empty();
      }
    }

    return reachableDependencies;
  }

  @override
  getDistinctDependencies(entity) {
    final dependencies = _dependencies[entity];

    if (dependencies != null) {
      return dependencies;
    }

    return _dependencies[entity] =
        super.getDistinctDependencies(entity).toSet();
  }

  @override
  getDependants(entity) {
    final dependants = _dependants[entity];

    if (dependants != null) {
      return dependants;
    }

    return _dependants[entity] = super.getDependants(entity).toSet();
  }

  @override
  deleteEntity(entity) {
    final dependencies = getDistinctDependencies(entity.identity);
    final dependants = getDependants(entity.identity);

    super.deleteEntity(entity);
    --_entityCount;
    _reachability.delete(entity.identity);
    _compromise.delete(entity.identity);
    _importance.clear(entity.identity);
    _notedEntities.remove(entity.identity);
    _dependencies.remove(entity.identity);
    _dependants.remove(entity.identity);

    for (final dependency in dependencies) {
      _dependants[dependency]?.remove(entity.identity);
    }
    for (final dependant in dependants) {
      _dependencies[dependant]?.remove(entity.identity);
    }

    _update();
  }

  @override
  addNote(entity, note) {
    super.addNote(entity, note);
    _notedEntities.add(entity.identity);
    _update();
  }

  @override
  removeNote(entity) {
    super.removeNote(entity);
    _notedEntities.remove(entity.identity);
    _update();
  }

  @override
  changeImportance(entity, value) {
    super.changeImportance(entity, value);
    _importance.change(entity.identity, value);
    _update();
  }

  @override
  toggleCompromised(entity, value) {
    super.toggleCompromised(entity, value);

    if (value) {
      _compromise.addOrigin(entity.identity);
    } else {
      _compromise.removeOrigin(entity.identity);
    }

    _update();
  }

  @override
  toggleLost(entity, value) {
    super.toggleLost(entity, value);

    if (value) {
      _reachability.addBlock(entity.identity);
    } else {
      _reachability.removeBlock(entity.identity);
    }

    _update();
  }

  @override
  changeThreshold(factor, value) {
    super.changeThreshold(factor, value);
    _reachability.rederive(factor.entity.identity);
    _compromise.rederive(factor.entity.identity);
    _update();
  }

  @override
  addDependencyAsFactor(entity, dependency) {
    super.addDependencyAsFactor(entity, dependency);
    _dependencies[entity.identity]?.add(dependency);
    _dependants[dependency]?.add(entity.identity);

    if (!_reachability.removeOrigin(entity.identity)) {
      _reachability.rederive(entity.identity);
    }

    _compromise.rederive(entity.identity);
    _importance.reevaluateOneWay([dependency]);
    _update();
  }

  @override
  addDependency(factor, entity) {
    super.addDependency(factor, entity);
    _dependencies[factor.entity.identity]?.add(entity);
    _dependants[entity]?.add(factor.entity.identity);
    _reachability.derive(factor.entity.identity);
    _compromise.derive(factor.entity.identity);
    _importance.reevaluateOneWay([entity]);
    _update();
  }

  @override
  removeDependency(dependency) {
    super.removeDependency(dependency);
    _dependencies.remove(dependency.factor.entity.identity);
    _dependants.remove(dependency.identity);
    _reachability.underive(dependency.factor.entity.identity);
    _compromise.underive(dependency.factor.entity.identity);
    _importance.reevaluateBothWays([dependency.identity]);
    _update();
  }

  @override
  moveDependency(dependency, factor) {
    super.moveDependency(dependency, factor);

    final identities = {
      dependency.factor.entity.identity,
      factor.entity.identity
    };

    if (identities.length > 1) {
      _dependencies.remove(dependency.factor.entity.identity);
      _dependencies[factor.entity.identity]?.add(dependency.identity);
      _dependants.remove(dependency.identity);
      _importance.reevaluateBothWays([dependency.identity]);
    }
    if (!_reachability.underive(dependency.factor.entity.identity)) {
      _reachability.derive(factor.entity.identity);
    }
    if (!_compromise.underive(dependency.factor.entity.identity)) {
      _compromise.derive(factor.entity.identity);
    }

    _update();
  }

  @override
  moveDependencyAsFactor(dependency, entity) {
    super.moveDependencyAsFactor(dependency, entity);

    final identities = {dependency.factor.entity.identity, entity.identity};

    if (identities.length > 1) {
      _dependencies.remove(dependency.factor.entity.identity);
      _dependencies[entity.identity]?.add(dependency.identity);
      _dependants.remove(dependency.identity);
      _importance.reevaluateBothWays([dependency.identity]);
    }
    if (!_reachability.removeOrigin(entity.identity) &&
        !_reachability.underive(dependency.factor.entity.identity)) {
      _reachability.rederive(entity.identity);
    }
    if (!_compromise.underive(dependency.factor.entity.identity)) {
      _compromise.rederive(entity.identity);
    }

    _update();
  }

  @override
  mergeFactors(into, from) {
    super.mergeFactors(into, from);

    final identities = {into.entity.identity, from.entity.identity};

    if (identities.length > 1) {
      _dependencies.clear();
      _dependants.clear();
      _importance.reevaluateBothWays(getDependencies(into.identity));
    }
    if (!_reachability.underive(from.entity.identity)) {
      _reachability.derive(into.entity.identity);
    }
    if (!_compromise.underive(from.entity.identity)) {
      _compromise.derive(into.entity.identity);
    }

    _update();
  }

  @override
  removeFactor(factor) {
    final dependencies = getDependencies(factor.identity);

    super.removeFactor(factor);
    _dependencies.remove(factor.entity.identity);
    dependencies.forEach(_dependants.remove);

    if (getFactors(factor.entity.identity).isEmpty) {
      _reachability.addOrigin(factor.entity.identity);
      _compromise.underive(factor.entity.identity);
    } else {
      _reachability.derive(factor.entity.identity);
      _compromise.derive(factor.entity.identity);
    }

    _importance.reevaluateBothWays(dependencies);
    _update();
  }

  @override
  addFactor(entity) {
    super.addFactor(entity);

    if (!_reachability.removeOrigin(entity.identity)) {
      _reachability.underive(entity.identity);
    }

    _compromise.underive(entity.identity);
    _update();
  }

  @override
  resetLoss() {
    super.resetLoss();
    _reachability.removeBlocks();
    _update();
  }

  @override
  resetCompromise() {
    super.resetCompromise();
    _compromise.removeOrigins();
    _update();
  }

  @override
  createEntity(position, name) {
    final identity = super.createEntity(position, name);

    _reachability.addOrigin(identity);
    ++_entityCount;
    _update();

    return identity;
  }

  @override
  int get entityCount => _entityCount;

  @override
  Iterable<Identity<Entity>> get notedEntities => _notedEntities;

  @override
  import(storage) {
    super.import(storage);
    _entityCount = super.entityCount;
    _notedEntities.addAll(super.notedEntities);
    _reachability.initialize(origins: originEntities, blocks: lostEntities);
    _compromise.initialize(origins: compromisedEntities);
    _importance.setAll(positiveImportance);
    _update();
  }

  void _update() {
    storageInsight.value = StorageInsight(
      totalImportance: _importance.sum,
      entityCount: _entityCount,
      lostEntityCount: _entityCount - _reachability.size,
      manuallyLostEntityCount: _reachability.blockCount,
      compromisedEntityCount: _compromise.size,
      noteCount: _notedEntities.length,
    );
    _entityInsightNotifier._update();
  }

  @override
  dispose() {
    entityInsightNotifier.dispose();
    storageInsight.dispose();
    super.dispose();
  }
}

class _ChangeNotifier extends ChangeNotifier {
  void _update() => notifyListeners();
}
