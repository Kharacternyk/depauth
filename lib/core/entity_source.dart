import 'position.dart';

sealed class EntitySource {}

class EntityFromPositionSource implements EntitySource {
  final Position position;

  const EntityFromPositionSource(this.position);
}

class NewEntitySource implements EntitySource {
  const NewEntitySource();
}
