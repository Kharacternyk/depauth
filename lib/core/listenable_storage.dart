import 'package:flutter/foundation.dart';

import 'boundaries.dart';
import 'position.dart';
import 'storage.dart';
import 'traversable_entity.dart';

class ListenableStorage extends Storage {
  ListenableStorage({
    required super.name,
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
  changeImportance(entity, value) {
    super.changeImportance(entity, value);
    _updateEntities([entity.position]);
  }

  @override
  toggleCompromised(entity, value) {
    super.toggleCompromised(entity, value);
    _updateEntities([entity.position]);
  }

  @override
  toggleLost(entity, value) {
    super.toggleLost(entity, value);
    _updateEntities([entity.position]);
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
  removeDependency(factor, entity) {
    super.removeDependency(factor, entity);
    _updateEntities([factor.entity.position]);
  }

  @override
  moveDependency(entity, {required from, required to}) {
    super.moveDependency(entity, from: from, to: to);
    _updateEntities([
      from.entity.position,
      if (to.entity.identity != from.entity.identity) to.entity.position,
    ]);
  }

  @override
  addFactor(entity) {
    super.addFactor(entity);
    _updateEntities([entity.position]);
  }

  @override
  removeFactor(factor) {
    super.removeFactor(factor);
    _updateEntities([factor.entity.position]);
  }

  @override
  resetLoss() {
    final positions = lostPositions;
    super.resetLoss();
    _updateEntities(positions);
  }

  @override
  resetCompromise() {
    final positions = compromisedPositions;
    super.resetCompromise();
    _updateEntities(positions);
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
