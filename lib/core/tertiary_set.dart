class TertiarySet<T> {
  final _trueKeys = <T>{};
  final _falseKeys = <T>{};
  final _nullKeys = <T>{};

  bool? operator [](T key) {
    if (_trueKeys.contains(key)) {
      return true;
    }
    if (_falseKeys.contains(key)) {
      return false;
    }
    return null;
  }

  void operator []=(T key, bool? value) {
    switch (value) {
      case true:
        _trueKeys.add(key);
        _falseKeys.remove(key);
        _nullKeys.remove(key);
      case false:
        _trueKeys.remove(key);
        _falseKeys.add(key);
        _nullKeys.remove(key);
      case null:
        _trueKeys.remove(key);
        _falseKeys.remove(key);
        _nullKeys.add(key);
    }
  }

  void makeAll(bool? value) {
    switch (value) {
      case true:
        _trueKeys.addAll(_falseKeys);
        _trueKeys.addAll(_nullKeys);
        _falseKeys.clear();
        _nullKeys.clear();
      case false:
        _falseKeys.addAll(_trueKeys);
        _falseKeys.addAll(_nullKeys);
        _trueKeys.clear();
        _nullKeys.clear();
      case null:
        _nullKeys.addAll(_trueKeys);
        _nullKeys.addAll(_falseKeys);
        _trueKeys.clear();
        _falseKeys.clear();
    }
  }

  T? getRandom(bool? value) {
    return switch (value) {
      true => _trueKeys.firstOrNull,
      false => _falseKeys.firstOrNull,
      null => _nullKeys.firstOrNull,
    };
  }

  void forget(T key) {
    _falseKeys.remove(key);
    _trueKeys.remove(key);
    _nullKeys.remove(key);
  }

  void clear() {
    _falseKeys.clear();
    _trueKeys.clear();
    _nullKeys.clear();
  }
}
