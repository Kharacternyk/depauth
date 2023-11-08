import 'importance.dart';
import 'importance_boost.dart';
import 'till_empty.dart';

class ImportanceMap<K> {
  final _own = <K, int>{};
  final _boosts = <K, ImportanceBoost<K>>{};
  final Iterable<K> Function(K) getDependencies;
  final Iterable<K> Function(K) getDependants;
  var _sum = 0;

  int get sum => _sum;

  ImportanceMap({required this.getDependencies, required this.getDependants});

  Importance<K> operator [](K key) {
    return Importance(_own[key] ?? 0, _boosts[key]);
  }

  void clear(K key) {
    final value = _own.remove(key);
    final boost = _boosts.remove(key);

    _sum -= value ?? 0;
    _sum -= boost?.value ?? 0;

    if (value != null || boost != null) {
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
      if (value >= importance.boostedValue) {
        _boosts.remove(key);
        _sum += value - importance.boostedValue;

        if (value > importance.boostedValue) {
          reevaluateOneWay(getDependencies(key));
        }
      } else if (boost != null) {
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
    final unseen = <K>{};

    for (final (key, value) in pairs) {
      if (!_own.containsKey(key)) {
        _own[key] = value;
        _sum += value;
        unseen.add(key);
      }
    }

    reevaluateOneWay(unseen.expand(getDependencies));
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
      final delta = (boost?.value ?? 0) - (importance.boost?.value ?? 0);

      if (boost != null && delta > 0) {
        _boosts[key] = boost;
        _sum += delta;

        return getDependencies(key);
      }

      return const Iterable.empty();
    });
  }

  void _reevaluateAll() {
    _boosts.clear();
    _sum = _own.values.fold(0, (sum, value) => sum + value);
    reevaluateOneWay(_own.keys.expand(getDependencies));
  }
}
