import 'package:flutter/material.dart';

import 'logotype.dart';
import 'widget_extension.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  build(context) {
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
          const AboutListTile(
            icon: Icon(Icons.info),
          ),
        ],
      ),
    );
  }
}
