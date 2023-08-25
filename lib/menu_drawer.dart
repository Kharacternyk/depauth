import 'package:flutter/material.dart';

import 'logotype.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  build(context) {
    return const NavigationDrawer(
      children: [
        DrawerHeader(child: Logotype()),
        AboutListTile(
          icon: Icon(Icons.info),
        ),
      ],
    );
  }
}
