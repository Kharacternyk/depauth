import 'package:depauth/core/conjunction.dart';
import 'package:depauth/core/disjunction.dart';
import 'package:test/test.dart';

void main() {
  test('conjunction probability', () {
    expect(const Conjunction([]).getProbability((_) => 0.5), equals(0));
    expect(const Conjunction([Disjunction({})]).getProbability((_) => 0.5),
        equals(0));
    expect(
        const Conjunction([
          Disjunction({1})
        ]).getProbability((_) => 0.5),
        equals(0.5));
    expect(
        const Conjunction([
          Disjunction({1, 2})
        ]).getProbability((_) => 0.5),
        equals(0.75));
    expect(
        const Conjunction([
          Disjunction({1, 2}),
          Disjunction({1, 2}),
        ]).getProbability((_) => 0.5),
        equals(0.75));
    expect(
        const Conjunction([
          Disjunction({1}),
          Disjunction({2}),
        ]).getProbability((_) => 0.5),
        equals(0.25));
    expect(
        const Conjunction([
          Disjunction({1, 2}),
          Disjunction({3, 4}),
        ]).getProbability((_) => 0.5),
        equals(0.75 * 0.75));
    expect(
        const Conjunction([
          Disjunction({1, 2}),
          Disjunction({2}),
        ]).getProbability((_) => 0.5),
        equals(0.5));
    expect(
        const Conjunction([
          Disjunction({1}),
          Disjunction({2}),
          Disjunction({3}),
        ]).getProbability((_) => 0.5),
        equals(0.125));
    expect(
        const Conjunction([
          Disjunction({1}),
          Disjunction({2}),
          Disjunction({1, 2}),
        ]).getProbability((_) => 0.5),
        equals(0.25));
    expect(
        const Conjunction([
          Disjunction({1, 2}),
          Disjunction({2, 3}),
          Disjunction({1, 3}),
        ]).getProbability((_) => 0.5),
        equals(0.75 * 3 - 0.875 * 2));
  });
}
