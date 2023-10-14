import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'card_dropdown.dart';
import 'core/traveler.dart';
import 'scaled_draggable.dart';
import 'tip.dart';

class StorageDirectoryDropdown extends StatelessWidget {
  final Iterable<String> siblingNames;
  final void Function(String) selectStorage;
  final void Function() createStorage;

  const StorageDirectoryDropdown({
    required this.siblingNames,
    required this.selectStorage,
    required this.createStorage,
    super.key,
  });

  @override
  build(context) {
    final messages = AppLocalizations.of(context)!;

    final dropdown = CardDropdown(
      leading: const Icon(Icons.folder),
      title: Text(messages.otherStorages),
      children: [
        if (siblingNames.isNotEmpty)
          ListTile(
            title: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final name in siblingNames)
                  ScaledDraggable(
                    key: ValueKey(name),
                    dragData: StorageTraveler(name),
                    needsMaterial: true,
                    child: ActionChip(
                      avatar: const Icon(Icons.file_open),
                      label: Text(name),
                      onPressed: () {
                        selectStorage(name);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ...[
          messages.newStorageTip,
          messages.selectStorageTip,
          messages.deleteStorageTip,
        ].map(Tip.onCard),
      ],
    );

    return DragTarget<CreationTraveler>(
      builder: (context, candidate, rejected) {
        return Card(
          color: candidate.isNotEmpty
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          child: dropdown,
        );
      },
      onAccept: (_) {
        createStorage();
      },
    );
  }
}
