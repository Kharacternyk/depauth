import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'about_dropdown.dart';
import 'card_dropdown.dart';
import 'card_form.dart';
import 'core/storage_insight.dart';
import 'debounced_text_field.dart';
import 'tip.dart';
import 'widget_extension.dart';

class StorageForm extends StatelessWidget {
  final String storageName;
  final StorageInsight insight;
  final VoidCallback resetLoss;
  final VoidCallback resetCompromise;
  final void Function(String) rename;
  final bool Function() isRenameCanceled;
  final List<Widget> children;

  const StorageForm({
    required this.storageName,
    required this.insight,
    required this.resetLoss,
    required this.resetCompromise,
    required this.rename,
    required this.isRenameCanceled,
    required this.children,
    super.key,
  });

  @override
  build(context) {
    final messages = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final bulkActionCount = [
      insight.lostEntityCount,
      insight.compromisedEntityCount
    ].where((count) => count > 0).length;

    return CardForm([
      ListTile(
        leading: const Icon(Icons.edit_document),
        title: DebouncedTextField(
          key: ValueKey(storageName),
          value: storageName,
          delay: const Duration(milliseconds: 200),
          commitValue: rename,
          hint: messages.name,
          isCanceled: isRenameCanceled,
        ),
      ).card,
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
            enabled: insight.lostEntityCount > 0,
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
        ].map(Tip.onSurfaceVariant),
      Tip.onSurfaceVariant(messages.autoSaveTip),
    ]);
  }
}
