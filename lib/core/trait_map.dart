import 'till_empty.dart';
import 'trait.dart';

class TraitMap<K> {
  final _own = <K>{};
  final _inherited = <K, InheritedTrait>{};
  final Iterable<K> Function(K) getAffected;
  final InheritedTrait? Function(K, bool Function(K) hasTrait) getTrait;

  TraitMap(this.getAffected, this.getTrait);

  Trait? operator [](K key) {
    if (_own.contains(key)) {
      return const OwnTrait();
    }

    return _inherited[key];
  }

  int get length => _own.length + _inherited.length;

  void toggle(K key, bool value) {
    if (value) {
      _own.add(key);
      _inherited.remove(key);
      reevaluateOneWay(getAffected(key));
    } else {
      _own.remove(key);
      _reevaluateAll();
    }
  }

  void setAll(Iterable<K> keys) {
    _own.addAll(keys);
    reevaluateOneWay(keys.expand(getAffected));
  }

  void clear() {
    _own.clear();
    _inherited.clear();
  }

  void reevaluateBothWays(Iterable<K> keys) {
    final oneWayKeys = <K>[];

    for (final key in keys) {
      if (!_own.contains(key)) {
        if (_inherited.containsKey(key)) {
          return _reevaluateAll();
        } else {
          oneWayKeys.add(key);
        }
      }
    }

    reevaluateOneWay(oneWayKeys);
  }

  void reevaluateOneWay(Iterable<K> keys) {
    keys.toSet().tillEmpty((key) {
      if (!_has(key)) {
        final trait = getTrait(key, _has);

        if (trait != null) {
          _inherited[key] = trait;

          return getAffected(key);
        }
      }

      return const Iterable.empty();
    });
  }

  void _reevaluateAll() {
    _inherited.clear();
    reevaluateOneWay(_own.expand(getAffected));
  }

  bool _has(K key) {
    return _own.contains(key) || _inherited.containsKey(key);
  }
}
