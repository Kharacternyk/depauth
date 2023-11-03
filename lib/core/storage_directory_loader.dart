import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' hide StorageDirectory;

import 'storage_directory.dart';
import 'storage_directory_configuration.dart';
import 'storage_directory_status.dart';

class StorageDirectoryLoader {
  final status = ValueNotifier<StorageDirectoryStatus>(
    const LoadingStorageDirectory(),
  );
  final StorageDirectoryConfiguration _configuration;
  final String lockFileName;

  StorageDirectoryLoader(this._configuration, this.lockFileName) {
    _load();
  }

  void dispose() {
    if (status case LoadedStorageDirectory status) {
      status.directory.dispose();
    }

    status.dispose();
  }

  void _load() async {
    final storagesDirectory = Platform.isAndroid
        ? await getApplicationDocumentsDirectory()
        : await getApplicationSupportDirectory();

    await storagesDirectory.create(recursive: true);

    final lockFilePath = join(storagesDirectory.path, lockFileName);
    final lockFile = await File(lockFilePath).open(mode: FileMode.write);

    status.value = const LockedStorageDirectory();

    await lockFile.lock(FileLock.blockingExclusive);

    status.value = const LoadingStorageDirectory();

    final storages = [
      await for (final file in storagesDirectory.list())
        if (file is File &&
            extension(file.path) == _configuration.applicationFileExtension)
          (
            name: basenameWithoutExtension(file.path),
            timestamp: (await file.stat()).accessed.microsecondsSinceEpoch,
          )
    ];

    storages.sort((first, second) {
      return second.timestamp.compareTo(first.timestamp);
    });

    final existingStorageNames = storages.map((storage) => storage.name);
    final storageNames = existingStorageNames.isEmpty
        ? [_configuration.newStorageName]
        : existingStorageNames;
    final activeStoragePath = join(storagesDirectory.path, storageNames.first);
    final activeStorage =
        await File(activeStoragePath).open(mode: FileMode.writeOnlyAppend);

    await activeStorage.lock(FileLock.blockingExclusive);
    await activeStorage.unlock();
    await activeStorage.close();

    status.value = LoadedStorageDirectory(
      StorageDirectory(
        storagesDirectory.path,
        storageNames,
        _configuration,
      ),
    );
  }
}
