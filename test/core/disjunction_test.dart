import 'package:depauth/core/disjunction.dart';
import 'package:test/test.dart';

void main() {
  test('disjunction probability', () {
    expect(const Disjunction({}).getProbability((_) => 0.5), equals(0));
    expect(const Disjunction({1}).getProbability((_) => 0.5), equals(0.5));
    expect(const Disjunction({1, 2}).getProbability((_) => 0.5), equals(0.75));
  });
}
