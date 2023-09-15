import 'dart:collection';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'insightful_storage.dart';
import 'pending_value_notifier.dart';

class StorageDirectory {
  final String storagesPath;
  final String applicationFileExtension;
  final String entityDuplicatePrefix;
  final String entityDuplicateSuffix;

  final Queue<PendingValueNotifier<String>> _storageNames;
  late var _currentStorage = _getStorage();

  Iterable<PendingValueNotifier<String>> get storageNames => _storageNames;
  InsightfulStorage get currentStorage => _currentStorage;

  StorageDirectory._(
    this._storageNames, {
    required this.storagesPath,
    required this.applicationFileExtension,
    required this.entityDuplicatePrefix,
    required this.entityDuplicateSuffix,
  });

  void switchStorage(PendingValueNotifier<String> name) {
    _currentStorage.dispose();
    _storageNames.remove(name);
    _storageNames.addFirst(name);
    _currentStorage = _getStorage();
  }

  Future<void> dispose() async {
    _currentStorage.dispose();
    await Future.wait(
      storageNames
          .where(
            (notifier) => notifier.dirty,
          )
          .map(
            (notifier) => File(_getPath(notifier.initialValue)).rename(
              _getPath(notifier.value),
            ),
          ),
    );
  }

  InsightfulStorage _getStorage() {
    return InsightfulStorage(
      _getPath(storageNames.first.initialValue),
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
      Queue.of(
        storageNames.map(PendingValueNotifier.new),
      ),
    );
  }
}

class _Storage {
  final String name;
  final int timestamp;

  const _Storage(this.name, this.timestamp);
}
