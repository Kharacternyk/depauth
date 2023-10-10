import 'entity.dart';

class EmbellishedEntity extends Entity {
  final bool lost;
  final bool compromised;
  final int importance;

  const EmbellishedEntity(
    super.identity,
    super.name,
    super.type, {
    required this.lost,
    required this.compromised,
    required this.importance,
  });
}
