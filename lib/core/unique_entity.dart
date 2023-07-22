import 'db.dart';
import 'entity.dart';

class UniqueEntity extends Entity {
  final Id<UniqueEntity> id;

  const UniqueEntity(this.id, super.name, super.type);
}
