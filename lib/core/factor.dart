import 'db.dart';
import 'entity.dart';

class Factor {
  final Id<Factor> id;
  final Iterable<Entity> dependencies;

  const Factor(this.id, this.dependencies);
}
