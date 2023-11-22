import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'about_dropdown.dart';
import 'card_dropdown.dart';
import 'card_form.dart';
import 'core/storage_insight.dart';
import 'tip.dart';
import 'widget_extension.dart';

class StorageForm extends StatelessWidget {
  final StorageInsight insight;
  final VoidCallback resetLoss;
  final VoidCallback resetCompromise;
  final List<Widget> children;

  const StorageForm({
    required this.insight,
    required this.resetLoss,
    required this.resetCompromise,
    required this.children,
    super.key,
  });

  @override
  build(context) {
    final messages = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final bulkActionCount = [
      insight.manuallyLostEntityCount,
      insight.compromisedEntityCount
    ].where((count) => count > 0).length;

    return CardForm([
      ...children,
      CardDropdown(
        leading: Badge.count(
          count: bulkActionCount,
          backgroundColor: colors.primaryContainer,
          textColor: colors.onPrimaryContainer,
          isLabelVisible: bulkActionCount > 0,
          child: const Icon(Icons.style),
        ),
        title: Text(messages.bulkCardActions),
        children: [
          ListTile(
            leading: const Icon(Icons.where_to_vote),
            title: Text(messages.resetLoss),
            onTap: resetLoss,
            enabled: insight.manuallyLostEntityCount > 0,
          ),
          ListTile(
            leading: const Icon(Icons.report_off),
            title: Text(messages.resetCompromise),
            onTap: resetCompromise,
            enabled: insight.compromisedEntityCount > 0,
          ),
        ],
      ).card,
      const AboutDropdown(),
      if (insight.entityCount > 0)
        ...[
          messages.newEntityTip,
          messages.editEntityTip,
          messages.moveEntityTip,
          messages.deleteEntityTip,
          messages.zoomTip,
        ].map(Tip.onSurfaceVariant),
      Tip.onSurfaceVariant(messages.autoSaveTip),
    ]);
  }
}
