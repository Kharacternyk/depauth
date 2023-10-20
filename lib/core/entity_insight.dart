import 'entity.dart';
import 'storage.dart';

class EntityInsight {
  final Iterable<Identity<Entity>> lossHeritage;
  final Iterable<Identity<Entity>> compromiseHeritage;
  final int ancestorCount;
  final int descendantCount;
  final int bubbledImportance;

  const EntityInsight({
    required this.lossHeritage,
    required this.compromiseHeritage,
    required this.ancestorCount,
    required this.descendantCount,
    required this.bubbledImportance,
  });
}
