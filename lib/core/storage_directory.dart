import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sanitize_filename/sanitize_filename.dart';

import 'insightful_storage.dart';
import 'set_queue.dart';
import 'storage_directory_configuration.dart';

class StorageDirectory {
  final String storagesPath;
  final SetQueue<String> _storageNames;
  final StorageDirectoryConfiguration configuration;

  final pendingOperationProgress = ValueNotifier<double?>(null);
  late final siblingNames = ValueNotifier<Iterable<String>>(_storageNames.tail);

  late var _currentStorage = _getStorage();

  InsightfulStorage get currentStorage => _currentStorage;

  StorageDirectory(
    this.storagesPath,
    Iterable<String> storageNames,
    this.configuration,
  ) : _storageNames = SetQueue(storageNames);

  void dispose() {
    pendingOperationProgress.dispose();
    siblingNames.dispose();
    currentStorage.dispose();
  }

  Future<String?> copyCurrentStorage() async {
    if (pendingOperationProgress.value != null) {
      return null;
    }

    final name = _deduplicateName(_sanitize(
      configuration.getNameOfStorageCopy(_currentStorage.name),
    ));

    pendingOperationProgress.value = 0;

    await for (final progress in _currentStorage.copy(_getPath(name))) {
      pendingOperationProgress.value = progress;
    }

    pendingOperationProgress.value = null;

    _storageNames.addSecond(name);
    siblingNames.value = _storageNames.tail;

    return name;
  }

  Future<void> deleteStorage(String name) async {
    if (pendingOperationProgress.value != null) {
      return;
    }

    if (_storageNames.contains(name) && name != _storageNames.first) {
      pendingOperationProgress.value = 0;
      await File(_getPath(name)).delete();
      pendingOperationProgress.value = null;

      _storageNames.remove(name);
      siblingNames.value = _storageNames.tail;
    }
  }

  Future<String?> createStorage() async {
    if (pendingOperationProgress.value != null) {
      return null;
    }

    final name = _deduplicateName(configuration.newStorageName);

    pendingOperationProgress.value = 0;
    await File(_getPath(name)).create();
    pendingOperationProgress.value = null;

    _storageNames.addSecond(name);
    siblingNames.value = _storageNames.tail;

    return name;
  }

  void switchStorage(String name) {
    if (pendingOperationProgress.value != null) {
      return;
    }

    _disposeCurrentStorage();
    _storageNames.addFirst(_sanitize(name));
    _currentStorage = _getStorage();
  }

  void _disposeCurrentStorage() {
    final initialCurrentStorageName = _storageNames.first;

    _storageNames.remove(initialCurrentStorageName);

    final actualCurrentStorageName =
        _deduplicateName(_sanitize(_currentStorage.name));

    if (actualCurrentStorageName != _currentStorage.name) {
      _currentStorage.name = actualCurrentStorageName;
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
      return configuration.newStorageName;
    }

    return sanitized;
  }

  String _deduplicateName(String name) {
    var deduplicatedName = name;
    var i = 0;

    while (_storageNames.contains(deduplicatedName)) {
      ++i;
      deduplicatedName = configuration.deduplicateStorageName(name, i);
    }

    return deduplicatedName;
  }

  InsightfulStorage _getStorage() {
    return InsightfulStorage(
      name: _storageNames.first,
      path: _getPath(_storageNames.first),
      entityDuplicatePrefix: configuration.entityDuplicatePrefix,
      entityDuplicateSuffix: configuration.entityDuplicateSuffix,
    );
  }

  String _getPath(String name) {
    return join(storagesPath, name + configuration.applicationFileExtension);
  }
}
