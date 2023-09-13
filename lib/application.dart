import 'dart:collection';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'core/insightful_storage.dart';
import 'menu_drawer.dart';
import 'storage_panel.dart';

class Application extends StatefulWidget {
  final String storagesPath;
  final Iterable<String> storageNames;

  const Application._(this.storagesPath, this.storageNames);

  static Future<Application> get() async {
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

    return Application._(storagesDirectory.path, storageNames);
  }

  @override
  createState() => _State();
}

class _State extends State<Application> {
  final pendingRenames = <String, String>{};
  late final storageNames = Queue.of(widget.storageNames);
  late final name = ValueNotifier(storageNames.first);
  late var storage = _getStorage();

  @override
  initState() {
    super.initState();
    AppLifecycleListener(onExitRequested: () async {
      storage.dispose();
      try {
        await Future.wait([
          for (final rename in pendingRenames.entries)
            File(_getPath(rename.key)).rename(_getPath(rename.value))
        ]);
      } catch (_) {}
      return AppExitResponse.exit;
    });
  }

  InsightfulStorage _getStorage() {
    return InsightfulStorage(
      _getPath(storageNames.first),
      entityDuplicatePrefix: ' (',
      entityDuplicateSuffix: ')',
    );
  }

  String _getPath(String name) {
    return join(widget.storagesPath, '${storageNames.first}.depauth');
  }

  @override
  build(context) {
    return MaterialApp(
      title: 'DepAuth',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: SafeArea(
        child: StoragePanel(
          name: name,
          storage: storage,
          drawer: MenuDrawer(
            storageName: name,
            siblingNames: storageNames.skip(1),
            selectSibling: (name) {
              setState(() {
                storage.dispose();
                storageNames.remove(name);
                storageNames.addFirst(name);
                storage = _getStorage();
              });
            },
          ),
        ),
      ),
    );
  }
}

class _Storage {
  final String name;
  final int timestamp;

  const _Storage(this.name, this.timestamp);
}
