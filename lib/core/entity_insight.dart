import 'trait.dart';

class EntityInsight {
  final Trait? loss;
  final Trait? compromise;
  final int ancestorCount;
  final int descendantCount;
  final int bubbledImportance;

  const EntityInsight({
    required this.loss,
    required this.compromise,
    required this.ancestorCount,
    required this.descendantCount,
    required this.bubbledImportance,
  });
}
