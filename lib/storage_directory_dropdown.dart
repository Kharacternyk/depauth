import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'core/traveler.dart';
import 'scaled_draggable.dart';

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

    final dropdown = ExpansionTile(
      shape: const Border(),
      collapsedShape: const Border(),
      leading: const Icon(Icons.file_copy),
      title: Text(messages.otherDocuments),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (siblingNames.isNotEmpty)
          ListTile(
            key: const ValueKey(0),
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
        ListTile(title: Text(messages.storageDirectoryFormTip)),
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
