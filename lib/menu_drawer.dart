import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'logotype.dart';

class MenuDrawer extends StatelessWidget {
  final VoidCallback resetLoss;
  final VoidCallback resetCompromise;

  const MenuDrawer({
    required this.resetLoss,
    required this.resetCompromise,
    super.key,
  });

  @override
  build(context) {
    final messages = AppLocalizations.of(context)!;

    return NavigationDrawer(
      children: [
        const DrawerHeader(child: Logotype()),
        ListTile(
          trailing: const Icon(Icons.where_to_vote),
          title: Text(messages.resetLoss),
          onTap: resetLoss,
        ),
        ListTile(
          trailing: const Icon(Icons.report_off),
          title: Text(messages.resetCompromise),
          onTap: resetCompromise,
        ),
        const AboutListTile(),
      ],
    );
  }
}
