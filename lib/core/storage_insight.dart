class StorageInsight {
  final int entityCount;
  final int lostEntityCount;
  final int compromisedEntityCount;

  const StorageInsight({
    required this.entityCount,
    required this.lostEntityCount,
    required this.compromisedEntityCount,
  });

  StorageInsight add({
    int all = 0,
    int lost = 0,
    int compromised = 0,
  }) {
    return StorageInsight(
      entityCount: entityCount + all,
      lostEntityCount: lostEntityCount + lost,
      compromisedEntityCount: compromisedEntityCount + compromised,
    );
  }

  @override
  operator ==(other) =>
      other is StorageInsight &&
      entityCount == other.entityCount &&
      lostEntityCount == other.lostEntityCount &&
      compromisedEntityCount == other.compromisedEntityCount;

  @override
  int get hashCode =>
      Object.hash(entityCount, lostEntityCount, compromisedEntityCount);
}
