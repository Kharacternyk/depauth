import 'package:flutter/foundation.dart';

import 'entity.dart';
import 'factor.dart';
import 'listenable_storage.dart';
import 'position.dart';
import 'storage.dart';

class InsightfulStorage extends ListenableStorage {
  final traitInsightNotifier = _ChangeNotifier();

  final Map<Identity<Entity>, bool> _entityLoss = {};
  final Map<Identity<Factor>, bool> _factorLoss = {};
  final Map<Identity<Entity>, bool> _entityCompromise = {};
  final Map<Identity<Factor>, bool> _factorCompromise = {};

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

  bool areAllFactorsCompromised(Identity<Entity> entity) {
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
              return entity.lost || hasLostFactor(entity.identity);
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
        final result =
            getDependencies(factor).any((dependency) => dependency.compromised);
        _factorCompromise[factor] = result;
        return result;
    }
  }

  @override
  void deleteEntity(Position position) {
    super.deleteEntity(position);
    _updateAll();
  }

  @override
  void toggleCompromised(Position position, bool value) {
    super.toggleCompromised(position, value);
    _updateCompromise();
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
    _updateAll();
  }

  @override
  void removeDependency(
    Position position,
    Identity<Factor> factor,
    Identity<Entity> entity,
  ) {
    super.removeDependency(position, factor, entity);
    _updateAll();
  }

  @override
  void addFactor(Position position, Identity<Entity> entity) {
    super.addFactor(position, entity);
    _updateAll();
  }

  @override
  void removeFactor(Position position, Identity<Factor> factor) {
    super.removeFactor(position, factor);
    _updateAll();
  }

  void _updateLoss() {
    _entityLoss.clear();
    _factorLoss.clear();
    traitInsightNotifier._update();
  }

  void _updateCompromise() {
    _entityCompromise.clear();
    _factorCompromise.clear();
    traitInsightNotifier._update();
  }

  void _updateAll() {
    _entityLoss.clear();
    _factorLoss.clear();
    _entityCompromise.clear();
    _factorCompromise.clear();
    traitInsightNotifier._update();
  }
}

class _ChangeNotifier extends ChangeNotifier {
  void _update() {
    notifyListeners();
  }
}
