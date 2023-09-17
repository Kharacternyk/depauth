import 'package:flutter/material.dart';

import 'core/edit_subject.dart';
import 'core/storage_directory.dart';
import 'storage_directory_form.dart';
import 'storage_panel.dart';
import 'widget_extension.dart';

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
  final formHasTraveler = ValueNotifier(false);
  final editSubject = ValueNotifier<EditSubject>(const StorageSubject());
  final siblingNames = ValueNotifier<Iterable<String>>(const []);
  StorageDirectory? storageDirectory;

  @override
  dispose() {
    formHasTraveler.dispose();
    editSubject.dispose();
    siblingNames.dispose();
    super.dispose();
  }

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
      siblingNames.value = directory.siblingNames;
    });
  }

  @override
  build(context) {
    if (storageDirectory case StorageDirectory storageDirectory) {
      final storage = storageDirectory.currentStorage;

      return (Iterable<String> siblingNames) {
        return StoragePanel(
          storage: storage,
          editSubject: editSubject,
          formHasTraveler: formHasTraveler,
          storageDirectoryForm: StorageDirectoryForm(
            hasTraveler: formHasTraveler,
            storageName: storage.name,
            siblingNames: siblingNames,
            selectStorage: (name) {
              setState(() {
                storageDirectory.switchStorage(name);
              });
              this.siblingNames.value = storageDirectory.siblingNames;
            },
            createStorage: () {
              setState(() {
                storageDirectory.createStorage();
              });
              this.siblingNames.value = storageDirectory.siblingNames;
            },
            editCurrentStorage: () {
              editSubject.value = const StorageSubject();
            },
          ),
          deleteStorage: (traveler) {
            storageDirectory.deleteStorage(traveler.storageName);
            this.siblingNames.value = storageDirectory.siblingNames;
          },
        );
      }.listen(siblingNames);
    }

    return const Center(child: CircularProgressIndicator());
  }
}
