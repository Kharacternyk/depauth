import 'unique_entity.dart';

class Factor {
  final int id;
  final Iterable<UniqueEntity> entities;

  const Factor(this.id, this.entities);
}
