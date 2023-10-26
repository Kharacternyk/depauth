import 'entity.dart';
import 'importance.dart';
import 'storage.dart';
import 'trait.dart';

class EntityInsight {
  final Trait? loss;
  final Trait? compromise;
  final int dependencyCount;
  final int dependantCount;
  final Importance<Identity<Entity>> importance;

  const EntityInsight({
    required this.loss,
    required this.compromise,
    required this.dependencyCount,
    required this.dependantCount,
    required this.importance,
  });
}
