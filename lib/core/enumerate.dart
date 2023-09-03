extension Enumerable<T> on Iterable<T> {
  Iterable<(int, T)> get enumerate sync* {
    var index = 0;
    for (final value in this) {
      yield (index, value);
      ++index;
    }
  }
}
