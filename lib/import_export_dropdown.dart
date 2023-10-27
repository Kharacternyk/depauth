import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';
import 'package:share_plus/share_plus.dart';

import 'card_dropdown.dart';
import 'context_messanger.dart';
import 'core/inactive_storage_directory.dart';
import 'core/storage.dart';
import 'core/traveler.dart';
import 'tip.dart';

class ImportExportDropdown extends StatelessWidget {
  final InactiveStorageDirectory directory;
  final String applicationFileExtension;
  late final _typeGroups = [
    XTypeGroup(extensions: [applicationFileExtension])
  ];

  ImportExportDropdown(
    this.directory,
    this.applicationFileExtension, {
    super.key,
  });

  @override
  build(context) {
    late final colors = Theme.of(context).colorScheme;
    final messages = AppLocalizations.of(context)!;
    final dropdown = CardDropdown(
      leading: const Icon(Icons.drive_file_move),
      title: Text(messages.importAndExport),
      children: [
        ListTile(
          leading: const Icon(Icons.note_add),
          title: Text(messages.importStorage),
          subtitle: Text(messages.importWarning),
          onTap: () async {
            if (directory.locked) {
              return;
            }

            final file = await openFile(acceptedTypeGroups: _typeGroups);

            if (file != null) {
              if (await Storage.isStorage(file)) {
                directory.importStorage(file);
              } else if (context.mounted) {
                context.pushMessage(messages.notStorage);
              }
            }
          },
        ),
        Tip.onCard(messages.exportTip),
      ],
    );

    return DragTarget<StorageTraveler>(
      builder: (context, candidate, rejected) {
        return Card(
          color: candidate.isNotEmpty ? colors.primaryContainer : null,
          child: dropdown,
        );
      },
      onWillAccept: (traveler) => !directory.locked,
      onAccept: (traveler) {
        directory.withLock(() async {
          await Share.shareXFiles([XFile(traveler.passport.path)]);
        });
      },
    );
  }
}
