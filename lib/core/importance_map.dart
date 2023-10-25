import 'importance.dart';
import 'importance_boost.dart';
import 'till_empty.dart';

class ImportanceMap<K> {
  final _own = <K, int>{};
  final _boosts = <K, ImportanceBoost<K>>{};
  final Iterable<K> Function(K) getDependencies;
  final Iterable<K> Function(K) getDependants;

  ImportanceMap({required this.getDependencies, required this.getDependants});

  Importance<K> operator [](K key) {
    return Importance(_own[key] ?? 0, _boosts[key]);
  }

  void clear(K key) {
    final value = _own.remove(key);
    final boost = _boosts.remove(value);

    if (value != null && boost == null) {
      _reevaluateAll();
    }
  }

  void change(K key, int value) {
    final importance = this[key];
    final boost = importance.boost;

    if (value > 0) {
      _own[key] = value;
    } else {
      _own.remove(key);
    }

    if (value > importance.value) {
      if (boost == null) {
        _boosts.remove(key);
        reevaluateOneWay(getDependencies(key));
      } else {
        _boosts[key] = ImportanceBoost(
          importance.boostedValue - value,
          boost.origin,
        );
      }
    } else if (value < importance.value) {
      if (boost == null) {
        _reevaluateAll();
      } else {
        _boosts[key] = ImportanceBoost(
          importance.boostedValue - value,
          boost.origin,
        );
      }
    }
  }

  void setAll(Iterable<(K, int)> pairs) {
    for (final (key, value) in pairs) {
      _own[key] = value;
    }

    _reevaluateAll();
  }

  void reevaluateBothWays(Iterable<K> keys) {
    if (keys.any((key) => this[key].boostedValue > 0)) {
      _reevaluateAll();
    } else {
      reevaluateOneWay(keys);
    }
  }

  void reevaluateOneWay(Iterable<K> keys) {
    keys.toSet().tillEmpty((key) {
      final importance = this[key];
      final boost = getDependants(key).map((dependant) {
        return ImportanceBoost(
          this[dependant].boostedValue - importance.value,
          dependant,
        );
      }).fold(null, ImportanceBoost.max);

      if (boost != null && boost.value > (importance.boost?.value ?? 0)) {
        _boosts[key] = boost;

        return getDependencies(key);
      }

      return const Iterable.empty();
    });
  }

  void _reevaluateAll() {
    _boosts.clear();
    reevaluateOneWay(_own.keys.expand(getDependencies));
  }
}
