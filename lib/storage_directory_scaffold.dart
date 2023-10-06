import 'package:flutter/material.dart';

import 'bottom_bar.dart';
import 'core/edit_subject.dart';
import 'core/storage_directory.dart';
import 'core/storage_directory_configuration.dart';
import 'core/storage_directory_loader.dart';
import 'core/traveler.dart';
import 'storage_directory_dropdown.dart';
import 'storage_insight_row.dart';
import 'storage_scaffold.dart';
import 'view_region.dart';
import 'view_region_indicator.dart';
import 'widget_extension.dart';

class StorageDirectoryScaffold extends StatefulWidget {
  final StorageDirectoryConfiguration configuration;
  final String applicationName;
  final String fallbackDocumentsPath;

  const StorageDirectoryScaffold(
    this.configuration, {
    required this.applicationName,
    required this.fallbackDocumentsPath,
    super.key,
  });

  @override
  createState() => _State();
}

class _State extends State<StorageDirectoryScaffold> {
  final formHasTraveler = ValueNotifier(false);
  final editSubject = ValueNotifier<EditSubject>(const StorageSubject());
  final viewRegion = ValueNotifier<ViewRegion>(
    const ViewRegion(aspectRatio: 1),
  );
  StorageDirectory? storageDirectory;

  @override
  dispose() {
    formHasTraveler.dispose();
    editSubject.dispose();
    viewRegion.dispose();
    storageDirectory?.dispose();
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    loadStorageDirectory(
      widget.configuration,
      applicationName: widget.applicationName,
      fallbackDocumentsPath: widget.fallbackDocumentsPath,
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
            },
            createStorage: storageDirectory.createStorage,
            copyCurrentStorage: storageDirectory.copyCurrentStorage,
            pendingOperationProgress: storageDirectory.pendingOperationProgress,
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
              }
            },
          ),
        );
      }.listen(storageDirectory.siblingNames);
    }

    return const Center(child: CircularProgressIndicator());
  }
}
