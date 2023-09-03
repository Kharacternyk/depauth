class StorageInsight {
  final int entityCount;
  final bool hasLostEntities;
  final bool hasCompromisedEntities;

  const StorageInsight({
    required this.entityCount,
    required this.hasLostEntities,
    required this.hasCompromisedEntities,
  });

  StorageInsight increment() => StorageInsight(
        entityCount: entityCount + 1,
        hasLostEntities: hasLostEntities,
        hasCompromisedEntities: hasCompromisedEntities,
      );
  StorageInsight decrement() => StorageInsight(
        entityCount: entityCount - 1,
        hasLostEntities: hasLostEntities,
        hasCompromisedEntities: hasCompromisedEntities,
      );

  @override
  bool operator ==(Object other) =>
      other is StorageInsight &&
      entityCount == other.entityCount &&
      hasLostEntities == other.hasLostEntities &&
      hasCompromisedEntities == other.hasCompromisedEntities;

  @override
  int get hashCode =>
      Object.hash(entityCount, hasLostEntities, hasCompromisedEntities);
}
