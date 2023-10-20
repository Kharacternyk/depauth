import 'entity.dart';
import 'storage.dart';

sealed class Trait {}

class OwnTrait implements Trait {
  const OwnTrait();
}

class InheritedTrait implements Trait {
  final Iterable<Identity<Entity>> heritage;

  const InheritedTrait(this.heritage);
}
