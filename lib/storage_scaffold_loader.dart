import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'storage_scaffold.dart';

class StorageScaffoldLoader extends StatelessWidget {
  const StorageScaffoldLoader({super.key});

  @override
  build(context) {
    final messages = AppLocalizations.of(context)!;

    return StorageScaffold(
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
