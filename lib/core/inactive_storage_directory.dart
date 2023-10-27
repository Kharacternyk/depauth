import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';

import 'storage_directory.dart';

abstract interface class InactiveStorageDirectory {
  bool get locked;
  ValueNotifier<Iterable<StoragePassport>> get inactiveStorages;

  Future<StoragePassport?> createStorage();
  Future<StoragePassport?> importStorage(XFile file);
  void switchStorage(StoragePassport storage);

  Future<T?> withLock<T>(Future<T> Function() operate);
}
