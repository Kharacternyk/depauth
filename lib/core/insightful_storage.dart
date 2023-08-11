import 'package:flutter/foundation.dart';

import 'entity.dart';
import 'factor.dart';
import 'listenable_storage.dart';
import 'position.dart';
import 'storage.dart';

class InsightfulStorage extends ListenableStorage {
  final lossChangeNotifier = _ChangeNotifier();

  final Map<Identity<Entity>, bool> _entityLoss = {};
  final Map<Identity<Factor>, bool> _factorLoss = {};

  InsightfulStorage(
    super.path, {
    required super.entityDuplicatePrefix,
    required super.entityDuplicateSuffix,
  });

  bool hasLostFactor(Identity<Entity> entity) {
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

  bool _isFactorLost(Identity<Factor> factor) {
    switch (_factorLoss[factor]) {
      case bool result:
        return result;
      case null:
        final dependencies = getDependencies(factor);
        final result = dependencies.isNotEmpty &&
            dependencies.every(
                (entity) => entity.lost || hasLostFactor(entity.identity));
        _factorLoss[factor] = result;
        return result;
    }
  }

  @override
  void deleteEntity(Position position) {
    super.deleteEntity(position);
    _updateLoss();
  }

  @override
  void toggleLost(Position position, bool value) {
    super.toggleLost(position, value);
    _updateLoss();
  }

  @override
  void addDependency(
    Position position,
    Identity<Factor> factor,
    Identity<Entity> entity,
  ) {
    super.addDependency(position, factor, entity);
    _updateLoss();
  }

  @override
  void removeDependency(
    Position position,
    Identity<Factor> factor,
    Identity<Entity> entity,
  ) {
    super.removeDependency(position, factor, entity);
    _updateLoss();
  }

  @override
  void addFactor(Position position, Identity<Entity> entity) {
    super.addFactor(position, entity);
    _updateLoss();
  }

  @override
  void removeFactor(Position position, Identity<Factor> factor) {
    super.removeFactor(position, factor);
    _updateLoss();
  }

  void _updateLoss() {
    _entityLoss.clear();
    _factorLoss.clear();
    lossChangeNotifier._update();
  }
}

class _ChangeNotifier extends ChangeNotifier {
  void _update() {
    notifyListeners();
  }
}
