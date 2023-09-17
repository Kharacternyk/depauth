import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'card_form.dart';
import 'core/traveler.dart';
import 'scaled_draggable.dart';
import 'widget_extension.dart';

class StorageDirectoryForm extends StatelessWidget {
  final ValueNotifier<bool> hasTraveler;
  final ValueNotifier<String> storageName;
  final Iterable<String> siblingNames;
  final void Function(String) selectStorage;
  final void Function() editCurrentStorage;
  final void Function() createStorage;

  const StorageDirectoryForm({
    required this.hasTraveler,
    required this.storageName,
    required this.editCurrentStorage,
    required this.siblingNames,
    required this.selectStorage,
    required this.createStorage,
    super.key,
  });

  @override
  build(context) {
    final messages = AppLocalizations.of(context)!;

    final form = CardForm([
      (String name) {
        return ListTile(
          leading: const Icon(Icons.edit_document),
          title: Text(name),
          onTap: editCurrentStorage,
          trailing: const Icon(Icons.arrow_forward),
        );
      }.listen(storageName).card,
      for (final name in siblingNames)
        ScaledDraggable(
          dragData: StorageTraveler(name),
          child: ListTile(
            leading: const Icon(Icons.file_open),
            title: Text(name),
            onTap: () {
              selectStorage(name);
            },
          ).card.keyed(ValueKey(name)),
        ),
      AboutListTile(
        icon: const Icon(Icons.info),
        aboutBoxChildren: [
          Text(messages.getHelp),
        ],
      ).card,
    ]);

    return DragTarget<CreationTraveler>(
      builder: (context, candidate, rejected) => form,
      onWillAccept: (_) => hasTraveler.value = true,
      onLeave: (_) => hasTraveler.value = false,
      onAccept: (_) {
        hasTraveler.value = false;
        createStorage();
      },
    );
  }
}
