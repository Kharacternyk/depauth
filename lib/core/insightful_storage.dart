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
  late var _entityCount = super.entityCount;

  InsightfulStorage({
    required super.name,
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
  deleteEntity(entity) {
    super.deleteEntity(entity);
    --_entityCount;
    _loss.toggle(entity.identity, false);
    _compromise.toggle(entity.identity, false);
    _importance.clear(entity.identity);
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
    _loss.reevaluateOneWay([entity.identity]);
    _compromise.reevaluateBothWays([entity.identity]);
    _importance.reevaluateOneWay([dependency]);
    _update();
  }

  @override
  addDependency(factor, entity) {
    super.addDependency(factor, entity);
    _loss.reevaluateBothWays([factor.entity.identity]);
    _compromise.reevaluateBothWays([factor.entity.identity]);
    _importance.reevaluateOneWay([entity]);
    _update();
  }

  @override
  removeDependency(dependency) {
    super.removeDependency(dependency);
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

    _loss.reevaluateBothWays(identities);
    _compromise.reevaluateBothWays(identities);

    if (identities.length > 1) {
      _importance.reevaluateBothWays([dependency.identity]);
    }

    _update();
  }

  @override
  moveDependencyAsFactor(dependency, entity) {
    super.moveDependencyAsFactor(dependency, entity);

    final identities = {dependency.factor.entity.identity, entity.identity};

    _loss.reevaluateBothWays(identities);
    _compromise.reevaluateBothWays(identities);

    if (identities.length > 1) {
      _importance.reevaluateBothWays([dependency.identity]);
    }

    _update();
  }

  @override
  mergeFactors(into, from) {
    super.mergeFactors(into, from);

    final identities = {into.entity.identity, from.entity.identity};

    _loss.reevaluateBothWays(identities);
    _compromise.reevaluateBothWays(identities);

    if (identities.length > 1) {
      _importance.reevaluateBothWays(getDependencies(into.identity));
    }

    _update();
  }

  @override
  removeFactor(factor) {
    final dependencies = getDependencies(factor.identity);

    super.removeFactor(factor);
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

  void _update() {
    storageInsight.value = StorageInsight(
      entityCount: _entityCount,
      lostEntityCount: _loss.length,
      compromisedEntityCount: _compromise.length,
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
