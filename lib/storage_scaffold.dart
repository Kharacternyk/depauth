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

  const StorageScaffold({
    required this.applicationName,
    required this.applicationFileExtension,
    required this.fallbackDocumentsPath,
    required this.defaultStorageName,
    required this.entityDuplicatePrefix,
    required this.entityDuplicateSuffix,
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
          select: (name) {
            setState(() {
              storageDirectory.switchStorage(name);
            });
          },
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }
}
