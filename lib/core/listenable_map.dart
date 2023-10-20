class ListenableMap<K, V> {
  final _map = <K, V>{};
  final void Function(K, ListenableMap<K, V>)? onSet;
  final void Function(K, ListenableMap<K, V>)? onUnset;

  ListenableMap({
    required this.onSet,
    required this.onUnset,
  });

  V? operator [](K key) => _map[key];

  void operator []=(K key, V? value) {
    if (value != null) {
      final wasUnset = !_map.containsKey(key);

      _map[key] = value;

      if (wasUnset) {
        onSet?.call(key, this);
      }
    } else {
      final wasSet = _map.containsKey(key);

      _map.remove(key);

      if (wasSet) {
        onUnset?.call(key, this);
      }
    }
  }

  void clear() => _map.clear();
}
