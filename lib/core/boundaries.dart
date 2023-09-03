import 'position.dart';

class Boundaries {
  final Position start;
  final Position end;

  const Boundaries(this.start, this.end);

  @override
  operator ==(other) =>
      other is Boundaries && start == other.start && end == other.end;

  @override
  int get hashCode => Object.hash(start, end);
}
