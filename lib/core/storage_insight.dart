class StorageInsight {
  final int entityCount;

  const StorageInsight({required this.entityCount});

  StorageInsight increment() => StorageInsight(entityCount: entityCount + 1);
  StorageInsight decrement() => StorageInsight(entityCount: entityCount - 1);
}
