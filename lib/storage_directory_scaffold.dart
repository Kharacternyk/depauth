import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'bottom_bar.dart';
import 'context_messanger.dart';
import 'core/edit_subject.dart';
import 'core/insightful_storage.dart';
import 'core/storage_directory.dart';
import 'core/storage_directory_configuration.dart';
import 'core/storage_directory_loader.dart';
import 'core/traveler.dart';
import 'import_export_dropdown.dart';
import 'storage_directory_dropdown.dart';
import 'storage_insight_row.dart';
import 'storage_scaffold.dart';
import 'view_region.dart';
import 'view_region_indicator.dart';
import 'widget_extension.dart';

class StorageDirectoryScaffold extends StatefulWidget {
  final StorageDirectoryConfiguration configuration;
  final String applicationName;

  const StorageDirectoryScaffold(
    this.configuration, {
    required this.applicationName,
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
    loadStorageDirectory(widget.configuration).then((directory) {
      setState(() {
        storageDirectory = directory;
      });
    });
  }

  @override
  build(context) {
    final storageDirectory = this.storageDirectory;

    if (storageDirectory == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final messages = AppLocalizations.of(context)!;
    final dropdown = StorageDirectoryDropdown(storageDirectory);

    return (InsightfulStorage storage) {
      return StorageScaffold(
        storage: storage,
        editSubject: editSubject,
        formHasTraveler: formHasTraveler,
        viewRegion: viewRegion,
        formChildren: [
          (double? progress) {
            return ListTile(
              title: Text(messages.copyStorage),
              leading: switch (progress) {
                null => const Icon(Icons.file_copy),
                double progress => SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(
                      value: progress > 0 ? progress : null,
                    ),
                  ),
              },
              enabled: progress == null,
              onTap: () async {
                final copy = await storageDirectory.copyActiveStorage();

                if (copy != null && context.mounted) {
                  context.pushMessage(messages.storageCopied(copy.name));
                }
              },
            );
          }.listen(storageDirectory.pendingOperationProgress).card,
          dropdown,
          ImportExportDropdown(
            storageDirectory,
            widget.configuration.applicationFileExtension,
          ),
        ],
        bottomBar: BottomBar(
          children: [
            ViewRegionIndicator.new.listen(viewRegion),
            StorageInsightRow.new.listen(storage.storageInsight),
          ],
          delete: (traveler) {
            switch (traveler) {
              case EntityTraveler traveler:
                storage.deleteEntity(traveler.passport);
              case FactorTraveler traveler:
                storage.removeFactor(traveler.passport);
              case DependencyTraveler traveler:
                storage.removeDependency(traveler.passport);
              case StorageTraveler traveler:
                storageDirectory.deleteStorage(traveler.passport);
            }
          },
        ),
      );
    }.listen(storageDirectory.activeStorage);
  }
}
