import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sanitize_filename/sanitize_filename.dart';

import 'insightful_storage.dart';
import 'set_queue.dart';

class StorageDirectory {
  final String storagesPath;
  final String applicationFileExtension;
  final String entityDuplicatePrefix;
  final String entityDuplicateSuffix;
  final String newStorageName;
  final String Function(String, int) deduplicateStorageName;

  final SetQueue<String> _storageNames;
  late var _currentStorage = _getStorage();

  Iterable<String> get siblingNames => _storageNames.tail;
  InsightfulStorage get currentStorage => _currentStorage;

  StorageDirectory._(
    this._storageNames, {
    required this.storagesPath,
    required this.applicationFileExtension,
    required this.entityDuplicatePrefix,
    required this.entityDuplicateSuffix,
    required this.newStorageName,
    required this.deduplicateStorageName,
  });

  void deleteStorage(String name) {
    if (_storageNames.contains(name) && name != _storageNames.first) {
      _storageNames.remove(name);
      File(_getPath(name)).deleteSync();
    }
  }

  void createStorage() {
    final current = _storageNames.first;
    final name = _deduplicateName(newStorageName);

    _storageNames.addFirst(name);
    _storageNames.addFirst(current);
    File(_getPath(name)).createSync();
  }

  void switchStorage(String name) {
    _disposeCurrentStorage();
    _storageNames.addFirst(_sanitize(name));
    _currentStorage = _getStorage();
  }

  void _disposeCurrentStorage() {
    final initialCurrentStorageName = _storageNames.first;

    _storageNames.remove(initialCurrentStorageName);

    final actualCurrentStorageName =
        _deduplicateName(_sanitize(_currentStorage.name.value));

    if (actualCurrentStorageName != _currentStorage.name.value) {
      _currentStorage.setName(actualCurrentStorageName);
    }

    _currentStorage.dispose();

    if (actualCurrentStorageName != initialCurrentStorageName) {
      File(_getPath(initialCurrentStorageName))
          .renameSync(_getPath(actualCurrentStorageName));
    }

    _storageNames.addFirst(actualCurrentStorageName);
  }

  String _sanitize(String name) {
    final sanitized = sanitizeFilename(name);

    if (sanitized.isEmpty) {
      return newStorageName;
    }

    return sanitized;
  }

  String _deduplicateName(String name) {
    var deduplicatedName = name;
    var i = 0;

    while (_storageNames.contains(deduplicatedName)) {
      ++i;
      deduplicatedName = deduplicateStorageName(name, i);
    }

    return deduplicatedName;
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
    required String entityDuplicatePrefix,
    required String entityDuplicateSuffix,
    required String applicationName,
    required String applicationFileExtension,
    required String newStorageName,
    required String Function(String, int) deduplicateStorageName,
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
      storageNames = [newStorageName];
    }

    return StorageDirectory._(
      storagesPath: storagesDirectory.path,
      applicationFileExtension: applicationFileExtension,
      entityDuplicateSuffix: entityDuplicateSuffix,
      entityDuplicatePrefix: entityDuplicatePrefix,
      deduplicateStorageName: deduplicateStorageName,
      newStorageName: newStorageName,
      SetQueue(storageNames),
    );
  }
}

class _Storage {
  final String name;
  final int timestamp;

  const _Storage(this.name, this.timestamp);
}
