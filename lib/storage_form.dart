import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'card_form.dart';
import 'core/storage_insight.dart';
import 'debounced_text_field.dart';
import 'tip.dart';
import 'widget_extension.dart';

class StorageForm extends StatelessWidget {
  final ValueNotifier<String> storageName;
  final StorageInsight insight;
  final VoidCallback resetLoss;
  final VoidCallback resetCompromise;
  final VoidCallback goBack;
  final void Function(String) rename;
  final bool Function() isRenameCanceled;

  const StorageForm({
    required this.storageName,
    required this.insight,
    required this.resetLoss,
    required this.resetCompromise,
    required this.goBack,
    required this.rename,
    required this.isRenameCanceled,
    super.key,
  });

  @override
  build(context) {
    final messages = AppLocalizations.of(context)!;

    return CardForm([
      ListTile(
        leading: const BackButtonIcon(),
        title: Text(messages.back),
        onTap: goBack,
      ).card,
      ListTile(
        leading: const Icon(Icons.edit_document),
        title: DebouncedTextField(
          value: storageName.value,
          delay: const Duration(milliseconds: 200),
          commitValue: rename,
          hint: messages.name,
          isCanceled: isRenameCanceled,
        ),
      ).card,
      ListTile(
        leading: const Icon(Icons.style),
        title: Text(messages.entityCount(insight.entityCount)),
      ).card,
      if (insight.hasLostEntities)
        ListTile(
          leading: const Icon(Icons.where_to_vote),
          title: Text(messages.resetLoss),
          onTap: resetLoss,
        ).card,
      if (insight.hasCompromisedEntities)
        ListTile(
          leading: const Icon(Icons.report_off),
          title: Text(messages.resetCompromise),
          onTap: resetCompromise,
        ).card,
      if (insight.entityCount > 0)
        ListTile(
          title: Tip(messages.storageFormTip),
        ),
    ]);
  }
}
