class PackedIntegerPair {
  final int first;
  final int second;

  static const _halfWidth = 16;

  int get packed => first << _halfWidth | second.toUnsigned(_halfWidth);

  PackedIntegerPair.fromPair(int first, int second)
      : first = first.toUnsigned(_halfWidth),
        second = second.toUnsigned(_halfWidth);
  PackedIntegerPair.fromPacked(int packed)
      : first = packed >>> _halfWidth,
        second = packed.toUnsigned(_halfWidth);
}
