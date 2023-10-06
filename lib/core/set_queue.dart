import 'dart:collection';

class SetQueue<T> {
  final Queue<T> _queue;
  final Set<T> _set;

  SetQueue(Iterable<T> elements)
      : _set = Set.of(elements),
        _queue = Queue.of(elements);

  bool contains(T element) => _set.contains(element);

  Iterable<T> get tail => _queue.skip(1);
  T get first => _queue.first;

  void remove(T element) {
    _set.remove(element);
    _queue.remove(element);
  }

  void addFirst(T element) {
    if (_set.contains(element)) {
      _queue.remove(element);
    } else {
      _set.add(element);
    }
    _queue.addFirst(element);
  }

  void addSecond(T element) {
    final first = this.first;

    remove(first);
    addFirst(element);
    addFirst(first);
  }
}
