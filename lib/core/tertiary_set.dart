class TertiarySet<T> {
  final _trueKeys = <T>{};
  final _falseKeys = <T>{};

  bool? operator [](T key) {
    return switch ((_trueKeys.contains(key), _falseKeys.contains(key))) {
      (true, true) => throw AssertionError('TertiarySet'),
      (true, false) => true,
      (false, true) => false,
      (false, false) => null,
    };
  }

  void operator []=(T key, bool? value) {
    switch (value) {
      case null:
        _trueKeys.remove(key);
        _falseKeys.remove(key);
      case true:
        _trueKeys.add(key);
        _falseKeys.remove(key);
      case false:
        _trueKeys.remove(key);
        _falseKeys.add(key);
    }
  }

  void makeAllFalse() {
    _falseKeys.addAll(_trueKeys);
    _trueKeys.clear();
  }

  void clear() {
    _falseKeys.clear();
    _trueKeys.clear();
  }
}
