import 'entity.dart';
import 'factor.dart';
import 'storage.dart';

class GroupedDependency {
  final Identity<Entity> entity;
  final Iterable<Identity<Factor>> factors;

  const GroupedDependency(this.entity, this.factors);
}
