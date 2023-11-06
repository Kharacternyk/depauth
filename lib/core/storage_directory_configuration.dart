class StorageDirectoryConfiguration {
  final String applicationFileExtension;
  final String entityDuplicatePrefix;
  final String entityDuplicateSuffix;
  final String newStorageName;
  final String Function(String, int) deduplicateStorageName;
  final String Function(String) getNameOfStorageCopy;
  final String mapFileName;
  final String importedStorageName;

  const StorageDirectoryConfiguration({
    required this.applicationFileExtension,
    required this.entityDuplicatePrefix,
    required this.entityDuplicateSuffix,
    required this.newStorageName,
    required this.deduplicateStorageName,
    required this.getNameOfStorageCopy,
    required this.mapFileName,
    required this.importedStorageName,
  });
}
