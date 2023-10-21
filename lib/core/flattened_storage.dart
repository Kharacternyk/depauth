import 'entity.dart';
import 'listenable_storage.dart';
import 'storage.dart';

class FlattenedStorage extends ListenableStorage {
  FlattenedStorage({
    required super.name,
    required super.path,
    required super.entityDuplicatePrefix,
    required super.entityDuplicateSuffix,
  });

  final _closures = <Identity<Entity>, Set<Identity<Entity>>>{};
  final _ancestors = <Identity<Entity>, Set<Identity<Entity>>>{};
  final _descendants = <Identity<Entity>, Set<Identity<Entity>>>{};

  Iterable<Identity<Entity>> getClosure(Identity<Entity> entity) {
    return _getClosure(entity);
  }

  Iterable<Identity<Entity>> getAncestors(Identity<Entity> entity) {
    return _getAncestors(entity);
  }

  Iterable<Identity<Entity>> getDescendants(Identity<Entity> entity) {
    return _getDescendants(entity);
  }

  Set<Identity<Entity>> _getClosure(Identity<Entity> entity) {
    if (_closures[entity] case Set<Identity<Entity>> closure) {
      return closure;
    }

    final ancestors = _getAncestors(entity);
    final descendants = _getDescendants(entity);

    return _closures[entity] = ancestors.intersection(descendants)..add(entity);
  }

  Set<Identity<Entity>> _getAncestors(Identity<Entity> entity) {
    if (_ancestors[entity] case Set<Identity<Entity>> ancestors) {
      return ancestors;
    }

    _ancestors[entity] = const {};

    final ancestors = getDistinctDependencies(entity)
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

  @override
  deleteEntity(entity) {
    _clearCoupling(upward: [entity.identity], downward: [entity.identity]);
    super.deleteEntity(entity);
  }

  @override
  addDependencyAsFactor(entity, dependency) {
    _clearCoupling(upward: [dependency], downward: [entity.identity]);
    super.addDependencyAsFactor(entity, dependency);
  }

  @override
  addDependency(factor, entity) {
    _clearCoupling(upward: [entity], downward: [factor.entity.identity]);
    super.addDependency(factor, entity);
  }

  @override
  removeDependency(dependency) {
    _clearCoupling(
      upward: [dependency.identity],
      downward: [dependency.factor.entity.identity],
    );
    super.removeDependency(dependency);
  }

  @override
  moveDependency(dependency, factor) {
    if (dependency.factor.entity.identity != factor.entity.identity) {
      _clearCoupling(
        upward: [dependency.identity],
        downward: [
          dependency.factor.entity.identity,
          factor.entity.identity,
        ],
      );
    }
    super.moveDependency(dependency, factor);
  }

  @override
  moveDependencyAsFactor(dependency, entity) {
    if (dependency.factor.entity.identity != entity.identity) {
      _clearCoupling(
        upward: [dependency.identity],
        downward: [
          dependency.factor.entity.identity,
          entity.identity,
        ],
      );
    }
    super.moveDependencyAsFactor(dependency, entity);
  }

  @override
  mergeFactors(into, from) {
    if (into.entity.identity != from.entity.identity) {
      final identities = [into, from].map((factor) => factor.entity.identity);
      _clearCoupling(upward: identities, downward: identities);
    }
    super.mergeFactors(into, from);
  }

  @override
  removeFactor(factor) {
    _clearCoupling(
      upward: getDependencies(factor.identity),
      downward: [factor.entity.identity],
    );
    super.removeFactor(factor);
  }

  void _clearCoupling({
    required Iterable<Identity<Entity>> upward,
    required Iterable<Identity<Entity>> downward,
  }) {
    final expandedUpward =
        upward.followedBy(upward.expand(getAncestors).toList());
    final expandedDownward =
        downward.followedBy(downward.expand(getDescendants).toList());

    expandedUpward.forEach(_closures.remove);
    expandedUpward.forEach(_descendants.remove);
    expandedDownward.forEach(_closures.remove);
    expandedDownward.forEach(_ancestors.remove);
  }
}
