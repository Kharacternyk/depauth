import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'card_dropdown.dart';
import 'context_messanger.dart';
import 'core/compatibility.dart';
import 'core/storage_schema.dart';
import 'core/storage_slot.dart';
import 'widget_extension.dart';

class ImportExportDropdown extends StatelessWidget {
  final StorageSlot slot;
  final String Function() getName;
  final String applicationFileExtension;
  late final _typeGroups = [
    XTypeGroup(extensions: [applicationFileExtension])
  ];

  ImportExportDropdown(
    this.slot,
    this.getName,
    this.applicationFileExtension, {
    super.key,
  });

  @override
  build(context) {
    late final theme = Theme.of(context);
    final messages = AppLocalizations.of(context)!;

    return CardDropdown(
      leading: const Icon(Icons.sync_alt),
      title: Text(messages.importAndExport),
      children: [
        ListTile(
          leading: const Icon(Icons.west),
          title: Text(messages.importStorage),
          onTap: () async {
            final file = await openFile(acceptedTypeGroups: _typeGroups);

            if (file != null) {
              final compatibility = await StorageSchema.getCompatibility(file);

              if (compatibility case CompatibilityMatch match) {
                slot.import(match.storage);
              } else if (context.mounted) {
                context.pushMessage(switch (compatibility) {
                  VersionMismatch _ => messages.versionMismatch,
                  _ => messages.notStorage,
                });
              }
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.east),
          title: Text(messages.exportStorage),
          onTap: () async {
            late final storage = slot.export().writeToBuffer();

            if (Platform.isAndroid) {
              final cacheDirectory = await getApplicationCacheDirectory();
              final file = await File(join(
                cacheDirectory.path,
                messages.exportedStorageName +
                    messages.applicationFileExtension,
              )).open(mode: FileMode.append);

              await file.lock(FileLock.blockingExclusive);
              await file.setPosition(0);
              await file.truncate(0);
              await file.writeFrom(storage);
              await file.unlock();
              await file.close();
              await Share.shareXFiles([XFile(file.path)]);
            } else {
              final name = getName() + applicationFileExtension;
              final location = await getSaveLocation(suggestedName: name);

              if (location != null) {
                await File(location.path).writeAsBytes(storage);
              }
            }
          },
        ),
      ],
    ).card;
  }
}
