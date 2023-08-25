import 'package:flutter/material.dart';

import 'logotype.dart';

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

    return NavigationDrawer(
      children: [
        const DrawerHeader(child: Logotype()),
        ...destinations,
        const AboutListTile(
          icon: Icon(Icons.info),
        ),
      ],
    );
  }
}
