class StorageInsight {
  final int totalImportance;
  final int entityCount;
  final int lostEntityCount;
  final int compromisedEntityCount;
  final int noteCount;

  const StorageInsight.zero()
      : totalImportance = 0,
        entityCount = 0,
        lostEntityCount = 0,
        compromisedEntityCount = 0,
        noteCount = 0;

  const StorageInsight({
    required this.totalImportance,
    required this.entityCount,
    required this.lostEntityCount,
    required this.compromisedEntityCount,
    required this.noteCount,
  });

  @override
  operator ==(other) =>
      other is StorageInsight &&
      totalImportance == other.totalImportance &&
      entityCount == other.entityCount &&
      lostEntityCount == other.lostEntityCount &&
      compromisedEntityCount == other.compromisedEntityCount &&
      noteCount == other.noteCount;

  @override
  int get hashCode {
    return Object.hash(
      totalImportance,
      entityCount,
      lostEntityCount,
      compromisedEntityCount,
      noteCount,
    );
  }
}
