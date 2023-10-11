void maybe<T>(T? value, void Function(T) callback) {
  if (value case T value) {
    callback(value);
  }
}
