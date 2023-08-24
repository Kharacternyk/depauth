import 'package:flutter/foundation.dart';

import 'boundaries.dart';
import 'entity.dart';
import 'entity_type.dart';
import 'factor.dart';
import 'position.dart';
import 'storage.dart';
import 'traversable_entity.dart';

class ListenableStorage extends Storage {
  ListenableStorage(
    super.path, {
    required super.entityDuplicatePrefix,
    required super.entityDuplicateSuffix,
  });

  final Map<Position, WeakReference<ValueNotifier<TraversableEntity?>>>
      _entities = {};
  late final ValueNotifier<Boundaries> boundaries = ValueNotifier(
    super.getBoundaries(),
  );
  final dependencyChangeNotifier = _ChangeNotifier();

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
  TraversableEntity? getEntity(Position position) {
    return switch (_entities[position]?.target?.value) {
      null => super.getEntity(position),
      TraversableEntity entity => entity,
    };
  }

  @override
  Identity<Entity>? getEntityIdentity(Position position) {
    return switch (_entities[position]?.target?.value) {
      null => super.getEntityIdentity(position),
      TraversableEntity entity => entity.identity,
    };
  }

  @override
  Boundaries getBoundaries() {
    return boundaries.value;
  }

  @override
  void moveEntity({required Position from, required Position to}) {
    super.moveEntity(from: from, to: to);
    _updateEntities([from, to].followedBy(getDependantPositions(to)));
    _updateBoundaries();
  }

  @override
  void deleteEntity(Position position) {
    final dependants = getDependantPositions(position);
    super.deleteEntity(position);
    _updateEntities([position].followedBy(dependants));
    _updateBoundaries();
  }

  @override
  void createEntity(Position position, String name) {
    super.createEntity(position, name);
    _updateEntities([position]);
    _updateBoundaries();
  }

  @override
  void changeName(Position position, String name) {
    super.changeName(position, name);
    _updateEntities([position].followedBy(getDependantPositions(position)));
  }

  @override
  void changeType(Position position, EntityType type) {
    super.changeType(position, type);
    _updateEntities([position].followedBy(getDependantPositions(position)));
    _updateDependencies();
  }

  @override
  void toggleCompromised(Position position, bool value) {
    super.toggleCompromised(position, value);
    _updateEntities([position]);
  }

  @override
  void toggleLost(Position position, bool value) {
    super.toggleLost(position, value);
    _updateEntities([position]);
  }

  @override
  void addDependencyAsFactor(
    Position position, {
    required Identity<Entity> entity,
    required Identity<Entity> dependency,
  }) {
    super.addDependencyAsFactor(
      position,
      entity: entity,
      dependency: dependency,
    );
    _updateEntities([position]);
    _updateDependencies();
  }

  @override
  void addDependency(
    Position position,
    Identity<Factor> factor,
    Identity<Entity> entity,
  ) {
    super.addDependency(position, factor, entity);
    _updateEntities([position]);
    _updateDependencies();
  }

  @override
  void removeDependency(
    Position position,
    Identity<Factor> factor,
    Identity<Entity> entity,
  ) {
    super.removeDependency(position, factor, entity);
    _updateEntities([position]);
    _updateDependencies();
  }

  @override
  void addFactor(Position position, Identity<Entity> entity) {
    super.addFactor(position, entity);
    _updateEntities([position]);
  }

  @override
  void removeFactor(Position position, Identity<Factor> factor) {
    super.removeFactor(position, factor);
    _updateEntities([position]);
    _updateDependencies();
  }

  @override
  void resetLoss() {
    final positions = getLostPositions();
    super.resetLoss();
    _updateEntities(positions);
  }

  @override
  void resetCompromise() {
    final positions = getCompromisedPositions();
    super.resetCompromise();
    _updateEntities(positions);
  }

  void _updateDependencies() {
    dependencyChangeNotifier._update();
  }

  void _updateBoundaries() {
    boundaries.value = super.getBoundaries();
  }

  void _updateEntities(Iterable<Position> positions) {
    for (final position in positions) {
      _entities[position]?.target?.value = super.getEntity(position);
    }
  }
}

class _ChangeNotifier extends ChangeNotifier {
  void _update() {
    notifyListeners();
  }
}
