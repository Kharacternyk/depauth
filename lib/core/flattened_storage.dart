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

  final _ancestors = <Identity<Entity>, Set<Identity<Entity>>>{};
  final _descendants = <Identity<Entity>, Set<Identity<Entity>>>{};

  Set<Identity<Entity>> getAncestors(Identity<Entity> entity) {
    if (_ancestors[entity] case Set<Identity<Entity>> ancestors) {
      return ancestors;
    }

    _ancestors[entity] = const {};

    final ancestors = getFactors(entity)
        .expand(getDependencies)
        .expand((entity) => getAncestors(entity).followedBy([entity]))
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

  Set<Identity<Entity>> getDescendants(Identity<Entity> entity) {
    if (_descendants[entity] case Set<Identity<Entity>> descendants) {
      return descendants;
    }

    _descendants[entity] = const {};

    final descendants = getDependants(entity)
        .expand(
            (dependant) => getDescendants(dependant).followedBy([dependant]))
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
  removeDependency(factor, entity) {
    _clearCoupling(upward: [entity], downward: [factor.entity.identity]);
    super.removeDependency(factor, entity);
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

    expandedUpward.forEach(_descendants.remove);
    expandedDownward.forEach(_ancestors.remove);
  }
}