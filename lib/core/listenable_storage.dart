import 'package:flutter/foundation.dart';

import 'position.dart';
import 'tracked_disposal_storage.dart';
import 'traversable_entity.dart';

class ListenableStorage extends TrackedDisposalStorage {
  ListenableStorage({
    required super.name,
    required super.path,
    required super.entityDuplicatePrefix,
    required super.entityDuplicateSuffix,
  });

  final _entities =
      <Position, WeakReference<ValueNotifier<TraversableEntity?>>>{};

  late final boundaries = ValueNotifier(super.getBoundaries());
  late final name = ValueNotifier(super.getName());

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
    return switch (_entities[position]?.target?.value) {
      null => super.getEntity(position),
      TraversableEntity entity => entity,
    };
  }

  @override
  getEntityIdentity(position) {
    return switch (_entities[position]?.target?.value) {
      null => super.getEntityIdentity(position),
      TraversableEntity entity => entity.identity,
    };
  }

  @override
  getBoundaries() {
    return boundaries.value;
  }

  @override
  moveEntity({required from, required to}) {
    super.moveEntity(from: from, to: to);
    _updateEntities([from, to].followedBy(getDependantPositions(to)));
    _updateBoundaries();
  }

  @override
  deleteEntity(position) {
    final dependants = getDependantPositions(position);
    super.deleteEntity(position);
    _updateEntities([position].followedBy(dependants));
    _updateBoundaries();
  }

  @override
  createEntity(position, name) {
    super.createEntity(position, name);
    _updateEntities([position]);
    _updateBoundaries();
  }

  @override
  changeName(position, name) {
    super.changeName(position, name);
    _updateEntityWithDependants(position);
  }

  @override
  changeType(position, type) {
    super.changeType(position, type);
    _updateEntityWithDependants(position);
  }

  @override
  changeImportance(position, value) {
    super.changeImportance(position, value);
    _updateEntityWithDependants(position);
  }

  @override
  toggleCompromised(position, value) {
    super.toggleCompromised(position, value);
    _updateEntityWithDependants(position);
  }

  @override
  toggleLost(position, value) {
    super.toggleLost(position, value);
    _updateEntityWithDependants(position);
  }

  @override
  addDependencyAsFactor(position, {required entity, required dependency}) {
    super.addDependencyAsFactor(
      position,
      entity: entity,
      dependency: dependency,
    );
    _updateEntities([position]);
  }

  @override
  addDependency(position, factor, entity) {
    super.addDependency(position, factor, entity);
    _updateEntities([position]);
  }

  @override
  removeDependency(position, factor, entity) {
    super.removeDependency(position, factor, entity);
    _updateEntities([position]);
  }

  @override
  addFactor(position, entity) {
    super.addFactor(position, entity);
    _updateEntities([position]);
  }

  @override
  removeFactor(position, factor) {
    super.removeFactor(position, factor);
    _updateEntities([position]);
  }

  @override
  resetLoss() {
    final positions = getLostPositions();
    super.resetLoss();
    _updateEntities(positions);
  }

  @override
  resetCompromise() {
    final positions = getCompromisedPositions();
    super.resetCompromise();
    _updateEntities(positions);
  }

  @override
  dispose() {
    boundaries.dispose();
    name.dispose();
    for (final entity in _entities.values) {
      entity.target?.dispose();
    }
    super.dispose();
  }

  @override
  getName() => name.value;

  @override
  setName(name) {
    super.setName(name);
    this.name.value = name;
  }

  void _updateBoundaries() {
    boundaries.value = super.getBoundaries();
  }

  void _updateEntityWithDependants(Position position) {
    _updateEntities([position].followedBy(getDependantPositions(position)));
  }

  void _updateEntities(Iterable<Position> positions) {
    for (final position in positions) {
      _entities[position]?.target?.value = super.getEntity(position);
    }
  }
}
