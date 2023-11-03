import 'storage_directory.dart';

sealed class StorageDirectoryStatus {}

class LoadedStorageDirectory implements StorageDirectoryStatus {
  final StorageDirectory directory;

  const LoadedStorageDirectory(this.directory);
}

class LoadingStorageDirectory implements StorageDirectoryStatus {
  const LoadingStorageDirectory();
}

class LockedStorageDirectory implements StorageDirectoryStatus {
  const LockedStorageDirectory();
}
