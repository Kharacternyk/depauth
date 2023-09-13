import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'core/insightful_storage.dart';

class ApplicationStorage extends InsightfulStorage {
  final ValueNotifier<String> name;
  AppLifecycleListener? _lifecycleListener;

  ApplicationStorage({
    required String name,
    required String path,
  })  : name = ValueNotifier(name),
        super(
          path,
          entityDuplicatePrefix: ' (',
          entityDuplicateSuffix: ')',
        ) {
    _lifecycleListener = AppLifecycleListener(onExitRequested: () async {
      super.dispose();
      return AppExitResponse.exit;
    });
  }

  @override
  dispose() {
    _lifecycleListener?.dispose();
    super.dispose();
  }
}
