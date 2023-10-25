class ImportanceBoost<T> {
  final int value;
  final T origin;

  const ImportanceBoost(this.value, this.origin);

  static ImportanceBoost<T>? max<T>(
    ImportanceBoost<T>? first,
    ImportanceBoost<T>? second,
  ) {
    return ((first?.value ?? 0) < (second?.value ?? 0)) ? second : first;
  }
}
