import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'card_dropdown.dart';
import 'core/inactive_storage_directory.dart';
import 'core/storage_directory.dart';
import 'core/traveler.dart';
import 'scaled_draggable.dart';
import 'tip.dart';
import 'widget_extension.dart';

class StorageDirectoryDropdown extends StatelessWidget {
  final InactiveStorageDirectory directory;

  const StorageDirectoryDropdown(this.directory, {super.key});

  @override
  build(context) {
    final messages = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    final dropdown = (Iterable<StoragePassport> storages) {
      return CardDropdown(
        leading: Badge.count(
          isLabelVisible: storages.isNotEmpty,
          count: storages.length,
          backgroundColor: colors.primaryContainer,
          textColor: colors.onPrimaryContainer,
          child: const Icon(Icons.inventory),
        ),
        title: Text(messages.otherStorages),
        children: [
          if (storages.isNotEmpty)
            ListTile(
              title: [
                for (final storage in storages)
                  ScaledDraggable(
                    key: ValueKey(storage),
                    dragData: StorageTraveler(storage),
                    needsMaterial: true,
                    child: ActionChip(
                      avatar: const Icon(Icons.file_open),
                      label: Text(storage.name),
                      onPressed: () {
                        directory.switchStorage(storage);
                      },
                    ),
                  ),
              ].wrap,
            ),
          ...[
            messages.newStorageTip,
            messages.selectStorageTip,
            messages.deleteStorageTip,
          ].map(Tip.onCard),
        ],
      );
    }.listen(directory.inactiveStorages);

    return DragTarget<CreationTraveler>(
      builder: (context, candidate, rejected) {
        return Card(
          color: candidate.isNotEmpty ? colors.primaryContainer : null,
          child: dropdown,
        );
      },
      onAccept: (_) {
        directory.createStorage();
      },
    );
  }
}
