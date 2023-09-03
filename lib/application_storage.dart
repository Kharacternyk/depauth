import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'core/insightful_storage.dart';

class ApplicationStorage extends InsightfulStorage {
  AppLifecycleListener? lifecycleListener;

  ApplicationStorage(
    super.path, {
    required super.entityDuplicatePrefix,
    required super.entityDuplicateSuffix,
  }) {
    lifecycleListener = AppLifecycleListener(onExitRequested: () {
      super.dispose();
      return Future.value(AppExitResponse.exit);
    });
  }

  @override
  dispose() {
    lifecycleListener?.dispose();
    super.dispose();
  }
}
