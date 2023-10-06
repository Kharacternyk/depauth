import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' hide StorageDirectory;

import 'storage_directory.dart';
import 'storage_directory_configuration.dart';

Future<StorageDirectory> loadStorageDirectory(
  StorageDirectoryConfiguration configuration, {
  required String fallbackDocumentsPath,
  required String applicationName,
}) async {
  var documentsDirectory = Directory(fallbackDocumentsPath);

  try {
    documentsDirectory = await getApplicationDocumentsDirectory();
  } on MissingPlatformDirectoryException {}

  final storagesDirectory = Directory(
    join(documentsDirectory.path, applicationName),
  );

  await storagesDirectory.create(recursive: true);

  final storages = <_Storage>[];

  await for (final file in storagesDirectory.list()) {
    if (file is File &&
        extension(file.path) == configuration.applicationFileExtension) {
      final stat = await file.stat();

      storages.add(
        _Storage(
          basenameWithoutExtension(file.path),
          stat.accessed.microsecondsSinceEpoch,
        ),
      );
    }
  }

  storages.sort((first, second) {
    return second.timestamp.compareTo(first.timestamp);
  });

  var storageNames = storages.map((storage) => storage.name);

  if (storageNames.isEmpty) {
    storageNames = [configuration.newStorageName];
  }

  return StorageDirectory(storagesDirectory.path, storageNames, configuration);
}

class _Storage {
  final String name;
  final int timestamp;

  const _Storage(this.name, this.timestamp);
}
