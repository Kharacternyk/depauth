import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'application_storage.dart';
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
      storageNames = ['Personal'];
    }

    return Application._(storagesDirectory.path, storageNames);
  }

  @override
  createState() => _State();
}

class _State extends State<Application> {
  late final storageNames = Queue.of(widget.storageNames);
  late var storage = ApplicationStorage(
    name: storageNames.first,
    path: join(widget.storagesPath, '${storageNames.first}.depauth'),
  );

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
          storage: storage,
          drawer: const MenuDrawer(),
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
