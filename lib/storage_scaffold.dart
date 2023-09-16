import 'package:flutter/material.dart';

import 'core/storage_directory.dart';
import 'menu_drawer.dart';
import 'storage_panel.dart';

class StorageScaffold extends StatefulWidget {
  final String applicationName;
  final String applicationFileExtension;
  final String fallbackDocumentsPath;
  final String defaultStorageName;
  final String entityDuplicatePrefix;
  final String entityDuplicateSuffix;
  final String newStorageName;
  final String Function(String, int) deduplicateStorageName;

  const StorageScaffold({
    required this.applicationName,
    required this.applicationFileExtension,
    required this.fallbackDocumentsPath,
    required this.defaultStorageName,
    required this.entityDuplicatePrefix,
    required this.entityDuplicateSuffix,
    required this.newStorageName,
    required this.deduplicateStorageName,
    super.key,
  });

  @override
  createState() => _State();
}

class _State extends State<StorageScaffold> {
  StorageDirectory? storageDirectory;

  @override
  initState() {
    super.initState();
    StorageDirectory.get(
      fallbackDocumentsPath: widget.fallbackDocumentsPath,
      defaultStorageName: widget.defaultStorageName,
      entityDuplicatePrefix: widget.entityDuplicatePrefix,
      entityDuplicateSuffix: widget.entityDuplicateSuffix,
      applicationName: widget.applicationName,
      applicationFileExtension: widget.applicationFileExtension,
      newStorageName: widget.newStorageName,
      deduplicateStorageName: widget.deduplicateStorageName,
    ).then((directory) {
      setState(() {
        storageDirectory = directory;
      });
    });
  }

  @override
  build(context) {
    if (storageDirectory case StorageDirectory storageDirectory) {
      final storage = storageDirectory.currentStorage;

      return StoragePanel(
        storage: storage,
        drawer: MenuDrawer(
          storageKey: ValueKey(storage),
          storageName: storage.name,
          rename: storage.setName,
          isRenameCanceled: () => storage.disposed,
          siblingNames: storageDirectory.siblingNames,
          selectStorage: (name) {
            setState(() {
              storageDirectory.switchStorage(name);
            });
          },
          createStorage: () {
            setState(() {
              storageDirectory.createStorage();
            });
          },
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }
}
