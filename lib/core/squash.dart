extension Squash<K, V> on Iterable<(K, V)> {
  Iterable<(K, Iterable<V>)> get squash sync* {
    var values = <V>[];
    K? current;

    for (final (key, value) in this) {
      if (key != current) {
        if (current != null) {
          yield (current, values);
          values = [];
        }
        current = key;
      }
      values.add(value);
    }

    if (current != null) {
      yield (current, values);
    }
  }
}
