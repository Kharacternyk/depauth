import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'logotype.dart';
import 'widget_extension.dart';

class MenuDrawer extends StatelessWidget {
  final ValueNotifier<String> storageName;
  final Iterable<String> siblingNames;
  final void Function(String) selectSibling;

  const MenuDrawer({
    required this.storageName,
    required this.siblingNames,
    required this.selectSibling,
    super.key,
  });

  @override
  build(context) {
    final messages = AppLocalizations.of(context)!;

    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            padding: EdgeInsets.zero,
            child: Ink(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const Logotype().pad(const EdgeInsets.all(8)),
            ),
          ),
          for (final name in siblingNames)
            ListTile(
              leading: const Icon(Icons.file_open),
              title: Text(name),
              onTap: () {
                selectSibling(name);
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
