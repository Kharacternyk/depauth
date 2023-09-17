import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'storage_directory_scaffold.dart';

class StorageDirectoryScaffoldLoader extends StatelessWidget {
  const StorageDirectoryScaffoldLoader({super.key});

  @override
  build(context) {
    final messages = AppLocalizations.of(context)!;

    return StorageDirectoryScaffold(
      applicationName: messages.applicationName,
      applicationFileExtension: messages.applicationFileExtension,
      entityDuplicatePrefix: messages.entityDuplicatePrefix,
      entityDuplicateSuffix: messages.entityDuplicateSuffix,
      defaultStorageName: messages.defaultStorageName,
      fallbackDocumentsPath: messages.fallbackDocumentsPath,
      newStorageName: messages.newStorageName,
      deduplicateStorageName: messages.deduplicatedStorageName,
    );
  }
}
