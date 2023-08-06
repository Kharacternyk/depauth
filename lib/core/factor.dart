import 'entity.dart';
import 'storage.dart';

class Factor {
  final Identity<Factor> identity;
  final Iterable<Entity> dependencies;

  const Factor(this.identity, this.dependencies);
}
