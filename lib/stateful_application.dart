import 'dart:collection';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'core/insightful_storage.dart';
import 'core/pending_value_notifier.dart';
import 'menu_drawer.dart';
import 'storage_panel.dart';

class StatefulApplication extends StatefulWidget {
  final String storagesPath;
  final Iterable<String> storageNames;

  const StatefulApplication._(this.storagesPath, this.storageNames);

  static Future<StatefulApplication> get() async {
    var documentsDirectory = Directory('.');

    try {
      documentsDirectory = await getApplicationDocumentsDirectory();
    } on MissingPlatformDirectoryException {}

    final storagesDirectory = Directory(
      join(documentsDirectory.path, 'DepAuth'),
    );

    await storagesDirectory.create(recursive: true);

    final storages = <_Storage>[];

    await for (final file in storagesDirectory.list()) {
      if (file is File && extension(file.path) == '.depauth') {
        final stat = await file.stat();

        storages.add(
          _Storage(
            basenameWithoutExtension(file.path),
            stat.accessed.microsecondsSinceEpoch,
          ),
        );
      }
    }

    storages.sort((first, second) {
      return first.timestamp - second.timestamp;
    });

    var storageNames = storages.map((storage) => storage.name);

    if (storageNames.isEmpty) {
      storageNames = const ['Personal'];
    }

    return StatefulApplication._(storagesDirectory.path, storageNames);
  }

  @override
  createState() => _State();
}

class _State extends State<StatefulApplication> {
  late final storageNames = Queue.of(
    widget.storageNames.map(PendingValueNotifier.new),
  );
  late var storage = _getStorage();

  @override
  initState() {
    super.initState();
    AppLifecycleListener(onExitRequested: () async {
      storage.dispose();
      try {
        await Future.wait(
          storageNames
              .where(
                (notifier) => notifier.dirty,
              )
              .map(
                (notifier) => File(_getPath(notifier.initialValue)).rename(
                  _getPath(notifier.value),
                ),
              ),
        );
      } catch (_) {}
      return AppExitResponse.exit;
    });
  }

  InsightfulStorage _getStorage() {
    return InsightfulStorage(
      _getPath(storageNames.first.initialValue),
      entityDuplicatePrefix: ' (',
      entityDuplicateSuffix: ')',
    );
  }

  String _getPath(String name) {
    return join(widget.storagesPath, '$name.depauth');
  }

  @override
  build(context) {
    return StoragePanel(
      name: storageNames.first,
      storage: storage,
      drawer: MenuDrawer(
        storageNames: storageNames,
        select: (name) {
          setState(() {
            storage.dispose();
            storageNames.remove(name);
            storageNames.addFirst(name);
            storage = _getStorage();
          });
        },
      ),
    );
  }
}

class _Storage {
  final String name;
  final int timestamp;

  const _Storage(this.name, this.timestamp);
}
