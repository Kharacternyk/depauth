import 'dart:io';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/insightful_storage.dart';

class ApplicationStorage extends InsightfulStorage {
  static const _storageListKey = 'storages';
  static SharedPreferences? _preferences;
  AppLifecycleListener? _lifecycleListener;

  ApplicationStorage(String path)
      : super(
          path,
          entityDuplicatePrefix: ' (',
          entityDuplicateSuffix: ')',
        ) {
    _lifecycleListener = AppLifecycleListener(onExitRequested: () {
      super.dispose();
      return Future.value(AppExitResponse.exit);
    });
  }

  @override
  dispose() {
    _lifecycleListener?.dispose();
    super.dispose();
  }

  static Future<Iterable<String>> listStorageNames() async {
    _preferences ??= await SharedPreferences.getInstance();
    return _preferences?.getStringList(_storageListKey) ?? const [];
  }

  static Future<ApplicationStorage> getStorage(String name) async {
    _preferences ??= await SharedPreferences.getInstance();

    await _preferences?.setStringList(_storageListKey, [
      name,
      ...?_preferences?.getStringList(_storageListKey),
    ]);

    return ApplicationStorage(join(
      await _getStorageDirectoryPath(),
      '$name.depauth',
    ));
  }

  static Future<String> _getStorageDirectoryPath() async {
    var globalPath = '.';

    try {
      globalPath = (await getApplicationDocumentsDirectory()).path;
    } on MissingPlatformDirectoryException {}

    final localPath = join(globalPath, 'DepAuth');

    await Directory(localPath).create(recursive: true);

    return localPath;
  }
}
