import 'package:depauth/core/flatten.dart';
import 'package:test/test.dart';

void main() {
  test('flatten', () {
    expect(
      flatten([
        [1],
        [2],
        [3]
      ]).expand((x) => x),
      unorderedEquals([
        1,
        2,
        3,
      ]),
    );
    expect(
      flatten([
        [1, 2],
        [2],
        [3]
      ]).expand((x) => x),
      unorderedEquals([
        1,
        2,
        3,
        2,
        2,
        3,
      ]),
    );
    expect(
      flatten([
        [1, 2],
        [2, 3],
      ]).expand((x) => x),
      unorderedEquals([
        1,
        2,
        2,
        2,
        1,
        3,
        2,
        3,
      ]),
    );
  });
}
