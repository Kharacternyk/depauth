import 'dart:io';

import 'inactive_storage_directory.dart';

extension StorageLimit on InactiveStorageDirectory {
  bool get storageLimitReached => Platform.isAndroid && storageCount >= 3;
}
