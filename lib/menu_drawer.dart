import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'debounced_text_field.dart';

class MenuDrawer extends StatelessWidget {
  final Key storageKey;
  final ValueNotifier<String> storageName;
  final void Function(String) rename;
  final Iterable<String> siblingNames;
  final void Function(String) select;

  const MenuDrawer({
    required this.storageKey,
    required this.storageName,
    required this.rename,
    required this.siblingNames,
    required this.select,
    super.key,
  });

  @override
  build(context) {
    final messages = AppLocalizations.of(context)!;

    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.edit_document),
            title: DebouncedTextField(
              key: storageKey,
              value: storageName.value,
              delay: const Duration(milliseconds: 200),
              commitValue: rename,
              hint: messages.name,
            ),
          ),
          const Divider(),
          for (final name in siblingNames)
            ListTile(
              leading: const Icon(Icons.file_open),
              title: Text(name),
              onTap: () {
                select(name);
              },
            ),
          const Divider(),
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
