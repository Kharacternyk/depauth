import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sanitize_filename/sanitize_filename.dart';

import 'inactive_storage_directory.dart';
import 'insightful_storage.dart';
import 'set_queue.dart';
import 'storage_directory_configuration.dart';

class StorageDirectory implements InactiveStorageDirectory {
  final String _path;
  final Iterable<String> _initialContent;
  final StorageDirectoryConfiguration _configuration;

  @override
  late final inactiveStorages = ValueNotifier(_storages.tail);
  late final activeStorage = ValueNotifier(_getStorage());
  late final _storages = SetQueue(_initialContent.map(_getInitialPassport));
  final pendingOperationProgress = ValueNotifier<double?>(null);
  var _locked = false;

  @override
  bool get locked => _locked;

  StorageDirectory(this._path, this._initialContent, this._configuration);

  void dispose() {
    pendingOperationProgress.dispose();
    inactiveStorages.dispose();
    activeStorage.dispose();
  }

  Future<StoragePassport?> copyActiveStorage() {
    return withLock(() async {
      final copy = _getPassport(
          _configuration.getNameOfStorageCopy(activeStorage.value.name));

      await for (final progress in activeStorage.value.copy(copy.path)) {
        pendingOperationProgress.value = progress;
      }

      _storages.addSecond(copy);
      inactiveStorages.value = _storages.tail;

      return copy;
    });
  }

  Future<void> deleteStorage(StoragePassport storage) {
    return withLock(() async {
      if (_storages.contains(storage) && storage != _storages.first) {
        await File(storage.path).delete();

        _storages.remove(storage);
        inactiveStorages.value = _storages.tail;
      }
    });
  }

  @override
  createStorage() {
    return withLock(() async {
      final storage = _getPassport();

      await File(storage.path).create();
      _storages.addSecond(storage);
      inactiveStorages.value = _storages.tail;

      return storage;
    });
  }

  @override
  importStorage(file) {
    return withLock(() async {
      final storage = _getPassport(withoutExtension(file.name));

      await file.saveTo(storage.path);
      _disposeActiveStorage();
      _storages.addFirst(storage);
      activeStorage.value = _getStorage();
      inactiveStorages.value = _storages.tail;

      return storage;
    });
  }

  @override
  switchStorage(storage) {
    if (locked) {
      return;
    }

    _disposeActiveStorage();
    _storages.addFirst(storage);
    activeStorage.value = _getStorage();
    inactiveStorages.value = _storages.tail;
  }

  @override
  withLock<T>(operate) async {
    if (!_locked) {
      pendingOperationProgress.value = 0;
      _locked = true;

      final result = await operate();

      _locked = false;
      pendingOperationProgress.value = null;

      return result;
    }

    return null;
  }

  void _disposeActiveStorage() {
    final initialStorage = _storages.first;

    _storages.remove(initialStorage);

    final updatedStorage = _getPassport(activeStorage.value.name);

    if (updatedStorage.name != activeStorage.value.name) {
      activeStorage.value.name = updatedStorage.name;
    }

    activeStorage.value.dispose();

    if (updatedStorage.name != initialStorage.name) {
      File(initialStorage.path).renameSync(updatedStorage.path);
    }

    _storages.addFirst(updatedStorage);
  }

  InsightfulStorage _getStorage() {
    try {
      return InsightfulStorage(
        name: _storages.first.name,
        path: _storages.first.path,
        entityDuplicatePrefix: _configuration.entityDuplicatePrefix,
        entityDuplicateSuffix: _configuration.entityDuplicateSuffix,
      );
    } on Exception {
      _storages.addFirst(_storages.tail.firstOrNull ?? _getPassport());
      return _getStorage();
    }
  }

  StoragePassport _getPassport([String name = '']) {
    final sanitized = sanitizeFilename(name);
    final notEmptySanitized =
        sanitized.isEmpty ? _configuration.newStorageName : sanitized;
    var deduplicated = _getInitialPassport(notEmptySanitized);

    for (var i = 1; _storages.contains(deduplicated); ++i) {
      deduplicated = _getInitialPassport(
        _configuration.deduplicateStorageName(notEmptySanitized, i),
      );
    }

    return deduplicated;
  }

  StoragePassport _getInitialPassport(String name) {
    return StoragePassport._(
      name: name,
      path: join(_path, name + _configuration.applicationFileExtension),
    );
  }
}

class StoragePassport {
  final String name;
  final String path;

  const StoragePassport._({required this.name, required this.path});

  @override
  operator ==(Object other) =>
      other is StoragePassport && name == other.name && path == other.path;

  @override
  int get hashCode => Object.hash(name, path);
}
