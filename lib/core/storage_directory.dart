import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sanitize_filename/sanitize_filename.dart';

import 'inactive_storage_directory.dart';
import 'insightful_storage.dart';
import 'set_queue.dart';
import 'storage_directory_configuration.dart';
import 'storage_directory_map.dart';
import 'storage_limit.dart';

class StorageDirectory implements InactiveStorageDirectory {
  final String _path;
  final Iterable<String> _initialContent;
  final StorageDirectoryConfiguration _configuration;

  @override
  late final inactiveStorages = ValueNotifier(_storages.tail);
  late final activeStorage = ValueNotifier(_getStorage());
  late final _map =
      StorageDirectoryMap(join(_path, _configuration.mapFileName));
  late final _storages = SetQueue(_initialContent.map(_getInitialPassport));
  final pendingOperationProgress = ValueNotifier<double?>(null);
  var _locked = false;

  @override
  int get storageCount => _storages.length;

  String get activeStorageName {
    return _map.activeStoragePendingName ?? _storages.first.name;
  }

  set activeStorageName(String value) {
    _map.activeStoragePendingName = value;
  }

  StorageDirectory(this._path, this._initialContent, this._configuration);

  void dispose() {
    pendingOperationProgress.dispose();
    inactiveStorages.dispose();
    activeStorage.dispose();
    _map.dispose();
  }

  Future<StoragePassport?> copyActiveStorage() {
    if (storageLimitReached) {
      return Future.value();
    }

    return _withLock(() async {
      final copy =
          _getPassport(_configuration.getNameOfStorageCopy(activeStorageName));

      await for (final progress in activeStorage.value.copy(copy.path)) {
        pendingOperationProgress.value = progress;
        activeStorage.value.touch();
      }

      activeStorage.value.touch();
      _storages.addSecond(copy);
      inactiveStorages.value = _storages.tail;

      return copy;
    });
  }

  Future<void> deleteStorage(StoragePassport storage) {
    return _withLock(() async {
      if (_storages.contains(storage) && storage != _storages.first) {
        await File(storage.path).delete();

        _storages.remove(storage);
        inactiveStorages.value = _storages.tail;
      }
    });
  }

  @override
  createStorage() {
    if (storageLimitReached) {
      return Future.value();
    }

    return _withLock(() async {
      final storage = _getPassport();

      await File(storage.path).create();
      activeStorage.value.touch();
      _storages.addSecond(storage);
      inactiveStorages.value = _storages.tail;

      return storage;
    });
  }

  @override
  switchStorage(storage) {
    if (_locked) {
      return;
    }

    _disposeActiveStorage();
    _storages.addFirst(storage);
    activeStorage.value = _getStorage();
    inactiveStorages.value = _storages.tail;
  }

  Future<T?> _withLock<T>(Future<T> Function() operate) async {
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
    final name = activeStorageName;

    _storages.remove(initialStorage);
    activeStorage.value.dispose();

    final updatedStorage = _getPassport(name);

    _storages.addFirst(updatedStorage);

    if (updatedStorage.name != initialStorage.name) {
      File(initialStorage.path).renameSync(updatedStorage.path);
    }

    _map.activeStoragePendingName = null;
  }

  InsightfulStorage _getStorage() {
    try {
      return InsightfulStorage(
        path: _storages.first.path,
        entityDuplicatePrefix: _configuration.duplicatePrefix,
        entityDuplicateSuffix: _configuration.duplicateSuffix,
      );
    } on Exception {
      if (kReleaseMode) {
        _storages.addFirst(_storages.tail.firstOrNull ?? _getPassport());
        return _getStorage();
      } else {
        rethrow;
      }
    }
  }

  StoragePassport _getPassport([String name = '']) {
    final sanitized = sanitizeFilename(name);
    final notEmptySanitized =
        sanitized.isEmpty ? _configuration.newStorageName : sanitized;
    final constrainedSanitized = notEmptySanitized.length > 100
        ? notEmptySanitized.substring(0, 100)
        : notEmptySanitized;
    var deduplicated = _getInitialPassport(constrainedSanitized);

    for (var i = 1; _storages.contains(deduplicated); ++i) {
      deduplicated = _getInitialPassport([
        constrainedSanitized,
        _configuration.duplicatePrefix,
        i,
        _configuration.duplicateSuffix,
      ].join());
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
