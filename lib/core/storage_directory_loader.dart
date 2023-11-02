import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' hide StorageDirectory;

import 'storage_directory.dart';
import 'storage_directory_configuration.dart';

Future<StorageDirectory> loadStorageDirectory(
  StorageDirectoryConfiguration configuration,
) async {
  final Directory storagesDirectory;

  if (Platform.isAndroid) {
    storagesDirectory = await getApplicationDocumentsDirectory();
  } else {
    storagesDirectory = await getApplicationSupportDirectory();
  }

  await storagesDirectory.create(recursive: true);

  final storages = [
    await for (final file in storagesDirectory.list())
      if (file is File &&
          extension(file.path) == configuration.applicationFileExtension)
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
      ? [configuration.newStorageName]
      : existingStorageNames;

  return StorageDirectory(storagesDirectory.path, storageNames, configuration);
}
