import 'entity.dart';
import 'listenable_storage.dart';
import 'maybe.dart';
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
  deleteEntity(position) {
    maybe(getEntityIdentity(position), (entity) {
      _clearCoupling(upward: [entity], downward: [entity]);
    });
    super.deleteEntity(position);
  }

  @override
  addDependencyAsFactor(position, {required entity, required dependency}) {
    _clearCoupling(upward: [dependency], downward: [entity]);
    super.addDependencyAsFactor(
      position,
      entity: entity,
      dependency: dependency,
    );
  }

  @override
  addDependency(position, factor, entity) {
    maybe(getEntityIdentity(position), (changedEntity) {
      _clearCoupling(upward: [entity], downward: [changedEntity]);
    });
    super.addDependency(position, factor, entity);
  }

  @override
  removeDependency(position, factor, entity) {
    maybe(getEntityIdentity(position), (changedEntity) {
      _clearCoupling(upward: [entity], downward: [changedEntity]);
    });
    super.removeDependency(position, factor, entity);
  }

  @override
  removeFactor(position, factor) {
    maybe(getEntityIdentity(position), (entity) {
      _clearCoupling(
        upward: getDependencies(factor),
        downward: [entity],
      );
    });
    super.removeFactor(position, factor);
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
