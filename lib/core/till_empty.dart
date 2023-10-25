extension TillEmpty<T> on Set<T> {
  void tillEmpty(Iterable<T> Function(T) expand) {
    while (isNotEmpty) {
      addAll(expand(first));
      remove(first);
    }
  }
}
