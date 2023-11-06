import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'bottom_bar.dart';
import 'context_messanger.dart';
import 'core/edit_subject.dart';
import 'core/insightful_storage.dart';
import 'core/storage_directory_configuration.dart';
import 'core/storage_directory_loader.dart';
import 'core/storage_directory_status.dart';
import 'core/traveler.dart';
import 'debounced_text_field.dart';
import 'import_export_dropdown.dart';
import 'pending_scaffold.dart';
import 'storage_directory_dropdown.dart';
import 'storage_insight_row.dart';
import 'storage_scaffold.dart';
import 'view_region.dart';
import 'view_region_indicator.dart';
import 'widget_extension.dart';

class StorageDirectoryScaffold extends StatefulWidget {
  final StorageDirectoryConfiguration configuration;
  final String lockFileName;

  const StorageDirectoryScaffold(
    this.configuration, {
    required this.lockFileName,
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
  late final loader = StorageDirectoryLoader(
    widget.configuration,
    lockFileName: widget.lockFileName,
  );

  @override
  dispose() {
    formHasTraveler.dispose();
    editSubject.dispose();
    viewRegion.dispose();
    loader.dispose();
    super.dispose();
  }

  @override
  build(context) {
    final messages = AppLocalizations.of(context)!;

    return (StorageDirectoryStatus status) {
      switch (status) {
        case LoadingStorageDirectory _:
          return PendingScaffold(messages.loadingStorageDirectory);
        case LockedStorageDirectory _:
          return PendingScaffold(messages.lockedStorageDirectory);
        case LoadedStorageDirectory status:
          final dropdown = StorageDirectoryDropdown(status.directory);

          return (InsightfulStorage storage) {
            return StorageScaffold(
              storage: storage,
              editSubject: editSubject,
              formHasTraveler: formHasTraveler,
              viewRegion: viewRegion,
              formChildren: [
                ListTile(
                  leading: const Icon(Icons.edit_document),
                  title: DebouncedTextField(
                    key: ObjectKey(storage),
                    getInitialValue: () => status.directory.activeStorageName,
                    delay: const Duration(milliseconds: 200),
                    commitValue: (value) {
                      status.directory.activeStorageName = value;
                    },
                    hint: messages.name,
                    isCanceled: () => storage.disposed,
                  ),
                ).card,
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
                      final copy = await status.directory.copyActiveStorage();

                      if (copy != null && context.mounted) {
                        context.pushMessage(messages.storageCopied(copy.name));
                      }
                    },
                  );
                }.listen(status.directory.pendingOperationProgress).card,
                dropdown,
                ImportExportDropdown(
                  status.directory,
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
                      status.directory.deleteStorage(traveler.passport);
                  }
                },
              ),
            );
          }.listen(status.directory.activeStorage);
      }
    }.listen(loader.status);
  }
}
