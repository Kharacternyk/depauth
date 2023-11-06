import 'package:flutter/foundation.dart';

import 'boundaries.dart';
import 'position.dart';
import 'storage.dart';
import 'traversable_entity.dart';

class ListenableStorage extends Storage {
  ListenableStorage({
    required super.path,
    required super.entityDuplicatePrefix,
    required super.entityDuplicateSuffix,
  });

  final _entities =
      <Position, WeakReference<ValueNotifier<TraversableEntity?>>>{};

  late final listenableBoundaries = ValueNotifier(super.boundaries);

  ValueNotifier<TraversableEntity?> getListenableEntity(Position position) {
    return switch (_entities[position]) {
      null => _cacheEntity(position),
      WeakReference<ValueNotifier<TraversableEntity?>> reference => switch (
            reference.target) {
          null => _cacheEntity(position),
          ValueNotifier<TraversableEntity?> entity => entity,
        },
    };
  }

  ValueNotifier<TraversableEntity?> _cacheEntity(Position position) {
    final entity = ValueNotifier(super.getEntity(position));

    _entities[position] = WeakReference(entity);

    return entity;
  }

  @override
  getEntity(position) {
    return switch (_entities[position]?.target) {
      null => super.getEntity(position),
      ValueNotifier<TraversableEntity?> entity => entity.value,
    };
  }

  @override
  Boundaries get boundaries {
    return listenableBoundaries.value;
  }

  @override
  moveEntity(entity, position) {
    final dependants = getDependantPositions(entity.identity);
    super.moveEntity(entity, position);
    // Moving an entity can impact the order of dependencies in dependants.
    _updateEntities([entity.position, position].followedBy(dependants));
    _updateBoundaries();
  }

  @override
  deleteEntity(entity) {
    final dependants = getDependantPositions(entity.identity);
    super.deleteEntity(entity);
    _updateEntities([entity.position].followedBy(dependants));
    _updateBoundaries();
  }

  @override
  createEntity(position, name) {
    super.createEntity(position, name);
    _updateEntities([position]);
    _updateBoundaries();
  }

  @override
  changeName(entity, name) {
    super.changeName(entity, name);
    _updateEntities(
      [entity.position].followedBy(getDependantPositions(entity.identity)),
    );
  }

  @override
  changeType(entity, type) {
    super.changeType(entity, type);
    _updateEntities(
      [entity.position].followedBy(getDependantPositions(entity.identity)),
    );
  }

  @override
  addDependencyAsFactor(entity, dependency) {
    super.addDependencyAsFactor(entity, dependency);
    _updateEntities([entity.position]);
  }

  @override
  addDependency(factor, entity) {
    super.addDependency(factor, entity);
    _updateEntities([factor.entity.position]);
  }

  @override
  removeDependency(dependency) {
    super.removeDependency(dependency);
    _updateEntities([dependency.factor.entity.position]);
  }

  @override
  moveDependency(dependency, factor) {
    super.moveDependency(dependency, factor);
    _updateEntities({
      factor.entity.position,
      dependency.factor.entity.position,
    });
  }

  @override
  moveDependencyAsFactor(dependency, entity) {
    super.moveDependencyAsFactor(dependency, entity);
    _updateEntities({entity.position, dependency.factor.entity.position});
  }

  @override
  addFactor(entity) {
    super.addFactor(entity);
    _updateEntities([entity.position]);
  }

  @override
  mergeFactors(into, from) {
    super.mergeFactors(into, from);
    _updateEntities({into.entity.position, from.entity.position});
  }

  @override
  removeFactor(factor) {
    super.removeFactor(factor);
    _updateEntities([factor.entity.position]);
  }

  @override
  dispose() {
    listenableBoundaries.dispose();
    for (final entity in _entities.values) {
      entity.target?.dispose();
    }
    super.dispose();
  }

  void _updateBoundaries() {
    listenableBoundaries.value = super.boundaries;
  }

  void _updateEntities(Iterable<Position> positions) {
    for (final position in positions) {
      _entities[position]?.target?.value = super.getEntity(position);
    }
  }
}
