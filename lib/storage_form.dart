import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'about_dropdown.dart';
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
  final List<Widget> leading;
  final List<Widget> trailing;

  const StorageForm({
    required this.storageName,
    required this.insight,
    required this.resetLoss,
    required this.resetCompromise,
    required this.rename,
    required this.isRenameCanceled,
    required this.leading,
    required this.trailing,
    super.key,
  });

  @override
  build(context) {
    final messages = AppLocalizations.of(context)!;

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
      ...leading,
      if (insight.lostEntityCount > 0)
        ListTile(
          leading: const Icon(Icons.where_to_vote),
          title: Text(messages.resetLoss),
          onTap: resetLoss,
        ).card.keyed(const ValueKey(0)),
      if (insight.compromisedEntityCount > 0)
        ListTile(
          leading: const Icon(Icons.report_off),
          title: Text(messages.resetCompromise),
          onTap: resetCompromise,
        ).card.keyed(const ValueKey(1)),
      ...trailing,
      const AboutDropdown(),
      if (insight.entityCount > 0)
        ...[
          messages.newEntityTip,
          messages.editEntityTip,
          messages.moveEntityTip,
          messages.deleteEntityTip,
        ].map(Tip.onSurfaceVariant),
    ]);
  }
}
