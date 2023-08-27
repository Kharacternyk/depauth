import 'package:flutter/material.dart';

import 'logotype.dart';
import 'widget_extension.dart';

class MenuDrawer extends StatelessWidget {
  final Iterable<String> fileDestinations;
  final void Function(String) changeDestination;

  const MenuDrawer({
    required this.fileDestinations,
    required this.changeDestination,
    super.key,
  });

  @override
  build(context) {
    final destinations = fileDestinations.map((file) {
      return ListTile(
        leading: const Icon(Icons.file_open),
        title: Text(file),
        onTap: () {
          Scaffold.of(context).closeDrawer();
          changeDestination(file);
        },
      );
    }).toList();

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
          ...destinations,
          const AboutListTile(
            icon: Icon(Icons.info),
          ),
        ],
      ),
    );
  }
}
