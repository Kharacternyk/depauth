import 'db.dart';
import 'unique_entity.dart';

class Factor {
  final Id<Factor> id;
  final Iterable<UniqueEntity> dependencies;

  const Factor(this.id, this.dependencies);
}
