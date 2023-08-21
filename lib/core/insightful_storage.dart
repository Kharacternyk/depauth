import 'package:flutter/foundation.dart';

import 'entity.dart';
import 'entity_insight.dart';
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

  EntityInsight getInsight(Identity<Entity> entity) {
    return EntityInsight(
      hasLostFactor: _hasLostFactor(entity),
      areAllFactorsCompromised: _areAllFactorsCompromised(entity),
      ancestorCount: _getAncestors(entity).length,
      descendantCount: _getDescendants(entity).length,
    );
  }

  Set<Identity<Entity>> _getAncestors(Identity<Entity> entity) {
    switch (_ancestors[entity]) {
      case Set<Identity<Entity>> ancestors:
        return ancestors;
      case null:
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
  }

  Set<Identity<Entity>> _getDescendants(Identity<Entity> entity) {
    switch (_descendants[entity]) {
      case Set<Identity<Entity>> descendants:
        return descendants;
      case null:
        _descendants[entity] = const {};

        final descendants = getDependants(entity)
            .expand((dependant) =>
                _getDescendants(dependant).followedBy([dependant]))
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
  }

  bool _hasLostFactor(Identity<Entity> entity) {
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

  bool _areAllFactorsCompromised(Identity<Entity> entity) {
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
              return entity.lost || _hasLostFactor(entity.identity);
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
              _areAllFactorsCompromised(dependency.identity);
        });
        _factorCompromise[factor] = result;
        return result;
    }
  }

  @override
  void deleteEntity(Position position) {
    _getEntity(position, (entity) {
      _clearCompromise(entity);
      _clearLoss(entity);
      _clearCoupling(upward: [entity], downward: [entity]);
      _update();
    });
    super.deleteEntity(position);
  }

  @override
  void toggleCompromised(Position position, bool value) {
    _getEntity(position, (entity) {
      _clearCompromise(entity, includingSelf: false);
      _update();
    });
    super.toggleCompromised(position, value);
  }

  @override
  void toggleLost(Position position, bool value) {
    _getEntity(position, (entity) {
      _clearLoss(entity, includingSelf: false);
      _update();
    });
    super.toggleLost(position, value);
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
      _update();
    });
    super.addDependency(position, factor, entity);
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
      _update();
    });
    super.removeDependency(position, factor, entity);
  }

  @override
  void addFactor(Position position, Identity<Entity> entity) {
    _getEntity(position, (entity) {
      _clearLoss(entity);
      _clearCompromise(entity);
      _update();
    });
    super.addFactor(position, entity);
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
      _update();
    });
    super.removeFactor(position, factor);
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
      _entityLoss.remove(entity);
    }
    _factorLoss.clear();
  }

  void _clearCompromise(Identity<Entity> entity, {bool includingSelf = true}) {
    for (final entity
        in _getDescendants(entity).followedBy([if (includingSelf) entity])) {
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
