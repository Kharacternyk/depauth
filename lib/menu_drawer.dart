import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'logotype.dart';
import 'widget_extension.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

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
