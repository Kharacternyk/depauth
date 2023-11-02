import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'core/storage_directory_configuration.dart';
import 'storage_directory_scaffold.dart';

class StorageDirectoryScaffoldLoader extends StatelessWidget {
  const StorageDirectoryScaffoldLoader({super.key});

  @override
  build(context) {
    final messages = AppLocalizations.of(context)!;

    return StorageDirectoryScaffold(
      StorageDirectoryConfiguration(
        applicationFileExtension: messages.applicationFileExtension,
        entityDuplicatePrefix: messages.entityDuplicatePrefix,
        entityDuplicateSuffix: messages.entityDuplicateSuffix,
        newStorageName: messages.newStorageName,
        deduplicateStorageName: messages.deduplicatedStorageName,
        getNameOfStorageCopy: messages.storageCopy,
      ),
      applicationName: messages.applicationName,
    );
  }
}
