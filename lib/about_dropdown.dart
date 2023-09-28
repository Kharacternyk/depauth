import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'card_dropdown.dart';
import 'widget_extension.dart';

class AboutDropdown extends StatelessWidget {
  const AboutDropdown({super.key});

  @override
  build(context) {
    final messages = AppLocalizations.of(context)!;

    return CardDropdown(
      leading: const Icon(Icons.info),
      title: Text(messages.about),
      children: [
        ListTile(
          leading: const Icon(Icons.public),
          title: Text(messages.website),
        ),
        ListTile(
          leading: const Icon(Icons.email),
          title: Text(messages.email),
        ),
        ListTile(
          leading: const Icon(Icons.balance),
          title: Text(messages.licenses),
          onTap: () {
            showLicensePage(context: context);
          },
        ),
      ],
    ).card;
  }
}
