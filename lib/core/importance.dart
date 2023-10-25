import 'importance_boost.dart';

class Importance<K> {
  final int value;
  final ImportanceBoost<K>? boost;

  const Importance(this.value, this.boost);

  int get boostedValue => value + (boost?.value ?? 0);
}
