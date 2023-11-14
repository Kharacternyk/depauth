import 'access.dart';
import 'entity.dart';
import 'importance.dart';
import 'storage.dart';

class EntityInsight {
  final Access<Identity<Entity>> reachability;
  final Access<Identity<Entity>> compromise;
  final int dependencyCount;
  final int dependantCount;
  final Importance<Identity<Entity>> importance;

  const EntityInsight({
    required this.reachability,
    required this.compromise,
    required this.dependencyCount,
    required this.dependantCount,
    required this.importance,
  });
}
