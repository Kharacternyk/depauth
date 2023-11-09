class PackedIntegerPair {
  final int first;
  final int second;

  int get packed => first << 16 | second.toUnsigned(16);

  PackedIntegerPair.fromPair(int first, int second)
      : first = first.toUnsigned(16),
        second = second.toUnsigned(16);
  PackedIntegerPair.fromPacked(int packed)
      : first = packed >>> 16,
        second = packed.toUnsigned(16);
}
