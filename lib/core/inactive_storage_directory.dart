import 'package:flutter/foundation.dart';

import 'storage_directory.dart';

abstract interface class InactiveStorageDirectory {
  ValueNotifier<Iterable<StoragePassport>> get inactiveStorages;
  Future<StoragePassport?> createStorage();
  Future<StoragePassport?> importStorage(String path);
  void switchStorage(StoragePassport storage);
  bool get locked;
  Future<T?> withLock<T>(Future<T> Function() operate);
}
