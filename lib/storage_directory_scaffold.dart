import 'package:flutter/material.dart';

import 'bottom_bar.dart';
import 'core/edit_subject.dart';
import 'core/storage_directory.dart';
import 'core/traveler.dart';
import 'storage_directory_dropdown.dart';
import 'storage_insight_row.dart';
import 'storage_scaffold.dart';
import 'view_region.dart';
import 'view_region_indicator.dart';
import 'widget_extension.dart';

class StorageDirectoryScaffold extends StatefulWidget {
  final String applicationName;
  final String applicationFileExtension;
  final String fallbackDocumentsPath;
  final String entityDuplicatePrefix;
  final String entityDuplicateSuffix;
  final String newStorageName;
  final String Function(String, int) deduplicateStorageName;

  const StorageDirectoryScaffold({
    required this.applicationName,
    required this.applicationFileExtension,
    required this.fallbackDocumentsPath,
    required this.entityDuplicatePrefix,
    required this.entityDuplicateSuffix,
    required this.newStorageName,
    required this.deduplicateStorageName,
    super.key,
  });

  @override
  createState() => _State();
}

class _State extends State<StorageDirectoryScaffold> {
  final formHasTraveler = ValueNotifier(false);
  final editSubject = ValueNotifier<EditSubject>(const StorageSubject());
  final siblingNames = ValueNotifier<Iterable<String>>(const []);
  final viewRegion = ValueNotifier<ViewRegion>(
    const ViewRegion(aspectRatio: 1),
  );
  StorageDirectory? storageDirectory;

  @override
  dispose() {
    formHasTraveler.dispose();
    editSubject.dispose();
    siblingNames.dispose();
    viewRegion.dispose();
    storageDirectory?.currentStorage.dispose();
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    StorageDirectory.get(
      fallbackDocumentsPath: widget.fallbackDocumentsPath,
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
        return StorageScaffold(
          storage: storage,
          editSubject: editSubject,
          formHasTraveler: formHasTraveler,
          viewRegion: viewRegion,
          storageDirectoryDropdown: StorageDirectoryDropdown(
            siblingNames: siblingNames,
            selectStorage: (name) {
              setState(() {
                storageDirectory.switchStorage(name);
              });
              this.siblingNames.value = storageDirectory.siblingNames;
            },
            createStorage: () {
              storageDirectory.createStorage();
              this.siblingNames.value = storageDirectory.siblingNames;
            },
          ),
          bottomBar: BottomBar(
            children: [
              ViewRegionIndicator.new.listen(viewRegion),
              StorageInsightRow.new.listen(
                storageDirectory.currentStorage.storageInsight,
              ),
            ],
            delete: (traveler) {
              switch (traveler) {
                case EntityTraveler traveler:
                  storage.deleteEntity(traveler.position);
                case FactorTraveler traveler:
                  storage.removeFactor(traveler.position, traveler.factor);
                case DependencyTraveler traveler:
                  storage.removeDependency(
                    traveler.position,
                    traveler.factor,
                    traveler.entity,
                  );
                case StorageTraveler traveler:
                  storageDirectory.deleteStorage(traveler.storageName);
                  this.siblingNames.value = storageDirectory.siblingNames;
              }
            },
          ),
        );
      }.listen(siblingNames);
    }

    return const Center(child: CircularProgressIndicator());
  }
}
