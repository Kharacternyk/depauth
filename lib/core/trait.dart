import 'entity.dart';
import 'storage.dart';

sealed class Trait {}

class OwnTrait implements Trait {
  const OwnTrait();
}

class InheritedTrait implements Trait {
  final Iterable<Identity<Entity>> from;

  const InheritedTrait(this.from);
}

extension IterableTrait on Trait? {
  Iterable<Identity<Entity>> get iterable {
    return switch (this) {
      InheritedTrait trait => trait.from,
      _ => const [],
    };
  }
}
