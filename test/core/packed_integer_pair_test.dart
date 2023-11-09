import 'package:depauth/core/packed_integer_pair.dart';
import 'package:glados/glados.dart';

void main() {
  Glados(any.uint32).test('An unpack followed by a pack is a no-op.',
      (integer) {
    final packed = PackedIntegerPair.fromPacked(integer);
    final (first, second) = (packed.first, packed.second);

    expect(PackedIntegerPair.fromPair(first, second).packed, integer);
  });
}
