import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'card_dropdown.dart';
import 'core/traveler.dart';
import 'scaled_draggable.dart';
import 'tip.dart';
import 'widget_extension.dart';

class StorageDirectoryDropdown extends StatelessWidget {
  final Iterable<String> siblingNames;
  final void Function(String) selectStorage;
  final void Function() createStorage;
  final void Function() copyCurrentStorage;
  final ValueNotifier<double?> pendingOperationProgress;

  const StorageDirectoryDropdown({
    required this.siblingNames,
    required this.selectStorage,
    required this.createStorage,
    required this.copyCurrentStorage,
    required this.pendingOperationProgress,
    super.key,
  });

  @override
  build(context) {
    final messages = AppLocalizations.of(context)!;

    final dropdown = CardDropdown(
      leading: const Icon(Icons.file_copy),
      title: Text(messages.otherStorages),
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
        (double? progress) {
          return ListTile(
            leading: const Icon(Icons.copy),
            title: switch (progress) {
              null => Text(messages.copyStorage),
              double progress => LinearProgressIndicator(value: progress),
            },
            onTap: progress == null ? copyCurrentStorage : null,
          );
        }.listen(pendingOperationProgress),
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
