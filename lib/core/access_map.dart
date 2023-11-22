import 'access.dart';
import 'till_empty.dart';

class AccessMap<K> {
  final _origins = <K>{};
  final _blocks = <K>{};
  final _derived = <K, Iterable<K>>{};
  final Iterable<K> Function(K) _getAffected;
  final Iterable<K> Function(K, bool Function(K)) _deriveFrom;

  AccessMap(this._getAffected, this._deriveFrom);

  Access<K> operator [](K key) {
    if (_blocks.contains(key)) {
      return const BlockedAccess();
    }
    if (_origins.contains(key)) {
      return const OriginAccess();
    }

    return DerivedAccess(_derived[key] ?? const Iterable.empty());
  }

  int get size => _origins
      .followedBy(_derived.keys)
      .where((element) => !_blocks.contains(element))
      .length;

  void addOrigin(K key) {
    if (!_origins.contains(key)) {
      _origins.add(key);

      if (!_blocks.contains(key)) {
        if (_derived.remove(key) == null) {
          _derive(_getAffected(key));
        }
      }
    }
  }

  bool removeOrigin(K key) =>
      _origins.remove(key) && !_blocks.contains(key) && _rederiveOne(key);

  void addBlock(K key) {
    if (!_blocks.contains(key)) {
      _blocks.add(key);

      if (_origins.contains(key) || _derived.containsKey(key)) {
        _rederiveOne(key);
      }
    }
  }

  void removeBlock(K key) {
    if (_blocks.remove(key)) {
      if (_origins.contains(key)) {
        _derive(_getAffected(key));
      } else {
        derive(key);
      }
    }
  }

  void initialize({
    required Iterable<K> origins,
    Iterable<K> blocks = const Iterable.empty(),
  }) {
    _origins.addAll(origins);
    _blocks.addAll(blocks);
    _derive(origins
        .where((origin) => !_blocks.contains(origin))
        .expand(_getAffected));
  }

  void removeOrigins() {
    _origins.clear();
    _derived.clear();
  }

  void removeBlocks() {
    if (_blocks.isNotEmpty) {
      _blocks.clear();
      _rederiveAll();
    }
  }

  void delete(K key) {
    final hasAccess = _hasAccess(key);

    _blocks.remove(key);
    _origins.remove(key);
    _derived.remove(key);

    if (hasAccess && _getAffected(key).isNotEmpty) {
      _rederiveAll();
    }
  }

  void rederive(K key) {
    if (!_origins.contains(key) && !_blocks.contains(key)) {
      if (_derived.containsKey(key)) {
        _rederiveOne(key);
      } else {
        derive(key);
      }
    }
  }

  bool underive(K key) => _derived.containsKey(key) && _rederiveOne(key);
  void derive(K key) => _derive([key]);

  void _derive(Iterable<K> keys) {
    keys.toSet().tillEmpty((key) {
      if (!_origins.contains(key) &&
          !_blocks.contains(key) &&
          !_derived.containsKey(key)) {
        final derivedFrom = _deriveFrom(key, _hasAccess);

        if (derivedFrom.isNotEmpty) {
          _derived[key] = derivedFrom;

          return _getAffected(key);
        }
      }

      return const Iterable.empty();
    });
  }

  bool _rederiveOne(K key) {
    if (_getAffected(key).isNotEmpty) {
      _rederiveAll();

      return true;
    }

    final derivedFrom = _deriveFrom(key, _hasAccess);

    if (derivedFrom.isNotEmpty) {
      _derived[key] = derivedFrom;
    } else {
      _derived.remove(key);
    }

    return false;
  }

  void _rederiveAll() {
    _derived.clear();
    _derive(_origins
        .where((origin) => !_blocks.contains(origin))
        .expand(_getAffected));
  }

  bool _hasAccess(K key) {
    return _origins.contains(key) && !_blocks.contains(key) ||
        _derived.containsKey(key);
  }
}
