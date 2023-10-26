import 'entity.dart';
import 'storage.dart';

class PassportlessEntity extends Entity {
  @override
  final Identity<Entity> identity;

  PassportlessEntity(this.identity, super.name, super.type);
}
