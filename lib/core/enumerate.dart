Iterable<(int, T)> enumerate<T>(Iterable<T> iterable) sync* {
  var index = 0;
  for (final value in iterable) {
    yield (index, value);
    ++index;
  }
}
