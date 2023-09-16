import 'dart:collection';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'insightful_storage.dart';

class StorageDirectory {
  final String storagesPath;
  final String applicationFileExtension;
  final String entityDuplicatePrefix;
  final String entityDuplicateSuffix;

  final Queue<String> _storageNames;
  late var _currentStorage = _getStorage();

  Iterable<String> get siblingNames => _storageNames.skip(1);
  InsightfulStorage get currentStorage => _currentStorage;

  StorageDirectory._(
    this._storageNames, {
    required this.storagesPath,
    required this.applicationFileExtension,
    required this.entityDuplicatePrefix,
    required this.entityDuplicateSuffix,
  });

  void switchStorage(String name) {
    ({String from, String to})? rename;

    if (_currentStorage.name.value != _storageNames.first) {
      rename = (
        from: _storageNames.first,
        to: _currentStorage.name.value,
      );
    }

    _currentStorage.dispose();

    if (rename != null) {
      File(_getPath(rename.from)).renameSync(_getPath(rename.to));
      _storageNames.removeFirst();
      _storageNames.addFirst(rename.to);
    }

    _storageNames.remove(name);
    _storageNames.addFirst(name);
    _currentStorage = _getStorage();
  }

  InsightfulStorage _getStorage() {
    return InsightfulStorage(
      name: _storageNames.first,
      path: _getPath(_storageNames.first),
      entityDuplicatePrefix: entityDuplicatePrefix,
      entityDuplicateSuffix: entityDuplicateSuffix,
    );
  }

  String _getPath(String name) {
    return join(storagesPath, name + applicationFileExtension);
  }

  static Future<StorageDirectory> get({
    required String fallbackDocumentsPath,
    required String defaultStorageName,
    required String entityDuplicatePrefix,
    required String entityDuplicateSuffix,
    required String applicationName,
    required String applicationFileExtension,
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
      if (file is File && extension(file.path) == applicationFileExtension) {
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
      storageNames = [defaultStorageName];
    }

    return StorageDirectory._(
      storagesPath: storagesDirectory.path,
      applicationFileExtension: applicationFileExtension,
      entityDuplicateSuffix: entityDuplicateSuffix,
      entityDuplicatePrefix: entityDuplicatePrefix,
      Queue.of(storageNames),
    );
  }
}

class _Storage {
  final String name;
  final int timestamp;

  const _Storage(this.name, this.timestamp);
}
