import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'card_form.dart';
import 'core/storage_insight.dart';
import 'tip.dart';
import 'widget_extension.dart';

class StorageForm extends StatelessWidget {
  final StorageInsight insight;
  final VoidCallback resetLoss;
  final VoidCallback resetCompromise;

  const StorageForm({
    required this.insight,
    required this.resetLoss,
    required this.resetCompromise,
    super.key,
  });

  @override
  build(context) {
    final messages = AppLocalizations.of(context)!;
    return CardForm([
      ListTile(
        leading: const Icon(Icons.numbers),
        title: Text(insight.entityCount.toString()),
      ).card,
      ListTile(
        leading: const Icon(Icons.where_to_vote),
        title: Text(messages.resetLoss),
        onTap: resetLoss,
      ).card,
      ListTile(
        leading: const Icon(Icons.report_off),
        title: Text(messages.resetCompromise),
        onTap: resetCompromise,
      ).card,
      ListTile(
        title: Tip(messages.storageFormTip),
      ),
    ]);
  }
}
