class StorageDirectoryConfiguration {
  final String applicationFileExtension;
  final String duplicatePrefix;
  final String duplicateSuffix;
  final String newStorageName;
  final String Function(String) getNameOfStorageCopy;
  final String mapFileName;
  final String importedStorageName;

  const StorageDirectoryConfiguration({
    required this.applicationFileExtension,
    required this.duplicatePrefix,
    required this.duplicateSuffix,
    required this.newStorageName,
    required this.getNameOfStorageCopy,
    required this.mapFileName,
    required this.importedStorageName,
  });
}
