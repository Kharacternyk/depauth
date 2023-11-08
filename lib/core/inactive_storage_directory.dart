import 'package:flutter/foundation.dart';

import 'storage_directory.dart';

abstract interface class InactiveStorageDirectory {
  ValueNotifier<Iterable<StoragePassport>> get inactiveStorages;
  Future<StoragePassport?> createStorage();
  void switchStorage(StoragePassport storage);
}
