Iterable<Iterable<T>> flatten<T>(Iterable<Iterable<T>> iterable) {
  var flatIterable = <Iterable<T>>[[]];

  for (final innerIterable in iterable) {
    final nextFlatIterable = <Iterable<T>>[];

    for (final element in innerIterable) {
      for (final innerFlatIterable in flatIterable) {
        nextFlatIterable.add(innerFlatIterable.followedBy([element]));
      }
    }

    flatIterable = nextFlatIterable;
  }

  return flatIterable;
}
