extension Interleavable<T> on Iterable<T> {
  Iterable<T> interleave(T separator) sync* {
    var first = true;

    for (final value in this) {
      if (!first) {
        yield separator;
      }
      yield value;
      first = false;
    }
  }
}
