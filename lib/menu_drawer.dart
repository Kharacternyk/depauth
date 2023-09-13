import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'core/pending_value_notifier.dart';
import 'debounced_text_field.dart';

class MenuDrawer extends StatelessWidget {
  final Iterable<PendingValueNotifier<String>> storageNames;
  final void Function(PendingValueNotifier<String>) select;

  const MenuDrawer({
    required this.storageNames,
    required this.select,
    super.key,
  });

  @override
  build(context) {
    final messages = AppLocalizations.of(context)!;

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: ListTile(
              leading: const Icon(Icons.edit),
              title: DebouncedTextField(
                key: ValueKey(storageNames.first.initialValue),
                value: storageNames.first.value,
                delay: const Duration(milliseconds: 200),
                commitValue: (value) {
                  storageNames.first.value = value;
                },
                hint: messages.name,
              ),
            ),
          ),
          for (final name in storageNames.skip(1))
            ListTile(
              leading: const Icon(Icons.file_open),
              title: Text(name.value),
              onTap: () {
                select(name);
              },
            ),
          AboutListTile(
            icon: const Icon(Icons.info),
            aboutBoxChildren: [
              Text(messages.getHelp),
            ],
          ),
        ],
      ),
    );
  }
}
