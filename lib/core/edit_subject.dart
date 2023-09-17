import 'position.dart';

sealed class EditSubject {}

class EntitySubject implements EditSubject {
  final Position position;
  const EntitySubject(this.position);
}

class StorageSubject implements EditSubject {
  const StorageSubject();
}

class StorageDirectorySubject implements EditSubject {
  const StorageDirectorySubject();
}
