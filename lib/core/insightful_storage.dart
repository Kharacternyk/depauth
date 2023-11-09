import 'package:flutter/foundation.dart';

import 'entity.dart';
import 'entity_insight.dart';
import 'entity_insight_origin.dart';
import 'importance_map.dart';
import 'listenable_storage.dart';
import 'storage.dart';
import 'storage_insight.dart';
import 'trait.dart';
import 'trait_map.dart';

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
    _loss.setAll(lostEntities);
    _compromise.setAll(compromisedEntities);
    _importance.setAll(positiveImportance);
    _update();
  }

  @override
  ChangeNotifier get entityInsightNotifier => _entityInsightNotifier;

  @override
  getEntityInsight(entity) {
    return EntityInsight(
      loss: _loss[entity],
      compromise: _compromise[entity],
      dependencyCount: getDistinctDependencies(entity).length,
      dependantCount: getDependants(entity).length,
      importance: _importance[entity],
    );
  }

  final _dependencies = <Identity<Entity>, Set<Identity<Entity>>>{};
  final _dependants = <Identity<Entity>, Set<Identity<Entity>>>{};
  late final _loss = TraitMap(
    getDependants,
    (entity, isLost) {
      final lostFactor =
          getFactors(entity).map(getDependencies).where((factor) {
        return factor.isNotEmpty && factor.every(isLost);
      }).firstOrNull;

      if (lostFactor != null) {
        return InheritedTrait(lostFactor);
      }

      return null;
    },
  );
  late final _compromise = TraitMap(
    getDependants,
    (entity, isCompromised) {
      final compromisedDependencies = <Identity<Entity>>{};
      final factors = getFactors(entity).map(getDependencies).where((factor) {
        return factor.isNotEmpty;
      });

      for (final factor in factors) {
        final compromisedDependency = factor.where(isCompromised).firstOrNull;

        if (compromisedDependency == null) {
          return null;
        } else {
          compromisedDependencies.add(compromisedDependency);
        }
      }

      return compromisedDependencies.isNotEmpty
          ? InheritedTrait(compromisedDependencies)
          : null;
    },
  );
  late final _importance = ImportanceMap(
    getDependants: getDependants,
    getDependencies: getDistinctDependencies,
  );

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
    _notedEntities.remove(entity.identity);
    _dependencies.remove(entity.identity);
    _dependants.remove(entity.identity);

    for (final dependency in dependencies) {
      _dependants[dependency]?.remove(entity.identity);
    }
    for (final dependant in dependants) {
      _dependencies[dependant]?.remove(entity.identity);
    }

    _loss.toggle(entity.identity, false);
    _compromise.toggle(entity.identity, false);
    _importance.clear(entity.identity);
    _update();
  }

  @override
  createNote(entity, note) {
    super.createNote(entity, note);
    _notedEntities.add(entity.identity);
    _update();
  }

  @override
  deleteNote(entity) {
    super.deleteNote(entity);
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
    _compromise.toggle(entity.identity, value);
    _update();
  }

  @override
  toggleLost(entity, value) {
    super.toggleLost(entity, value);
    _loss.toggle(entity.identity, value);
    _update();
  }

  @override
  addDependencyAsFactor(entity, dependency) {
    super.addDependencyAsFactor(entity, dependency);
    _dependencies[entity.identity]?.add(dependency);
    _dependants[dependency]?.add(entity.identity);
    _loss.reevaluateOneWay([entity.identity]);
    _compromise.reevaluateBothWays([entity.identity]);
    _importance.reevaluateOneWay([dependency]);
    _update();
  }

  @override
  addDependency(factor, entity) {
    super.addDependency(factor, entity);
    _dependencies[factor.entity.identity]?.add(entity);
    _dependants[entity]?.add(factor.entity.identity);
    _loss.reevaluateBothWays([factor.entity.identity]);
    _compromise.reevaluateBothWays([factor.entity.identity]);
    _importance.reevaluateOneWay([entity]);
    _update();
  }

  @override
  removeDependency(dependency) {
    super.removeDependency(dependency);
    _dependencies.remove(dependency.factor.entity.identity);
    _dependants.remove(dependency.identity);
    _loss.reevaluateBothWays([dependency.factor.entity.identity]);
    _compromise.reevaluateBothWays([dependency.factor.entity.identity]);
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

    _loss.reevaluateBothWays(identities);
    _compromise.reevaluateBothWays(identities);
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

    _loss.reevaluateBothWays(identities);
    _compromise.reevaluateBothWays(identities);
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

    _loss.reevaluateBothWays(identities);
    _compromise.reevaluateBothWays(identities);
    _update();
  }

  @override
  removeFactor(factor) {
    final dependencies = getDependencies(factor.identity);

    super.removeFactor(factor);
    _dependencies.remove(factor.entity.identity);
    dependencies.forEach(_dependants.remove);
    _loss.reevaluateBothWays([factor.entity.identity]);
    _compromise.reevaluateBothWays([factor.entity.identity]);
    _importance.reevaluateBothWays(dependencies);
    _update();
  }

  @override
  resetLoss() {
    super.resetLoss();
    _loss.clear();
    _update();
  }

  @override
  resetCompromise() {
    super.resetCompromise();
    _compromise.clear();
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

  @override
  Iterable<Identity<Entity>> get notedEntities => _notedEntities;

  @override
  import(storage) {
    super.import(storage);
    _entityCount = super.entityCount;
    _notedEntities.addAll(super.notedEntities);
    _loss.setAll(lostEntities);
    _compromise.setAll(compromisedEntities);
    _importance.setAll(positiveImportance);
    _update();
  }

  void _update() {
    storageInsight.value = StorageInsight(
      totalImportance: _importance.sum,
      entityCount: _entityCount,
      lostEntityCount: _loss.length,
      compromisedEntityCount: _compromise.length,
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
