import 'unique_entity.dart';

class Factor {
  final int id;
  final Iterable<UniqueEntity> dependencies;

  const Factor(this.id, this.dependencies);
}
