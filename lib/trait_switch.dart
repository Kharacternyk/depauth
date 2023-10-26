import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'core/active_record_storage.dart';
import 'core/trait.dart';
import 'entity_chip.dart';
import 'widget_extension.dart';

class TraitSwitch extends StatelessWidget {
  final ActiveRecordStorage storage;
  final Trait? trait;
  final String name;
  final Widget icon;
  final void Function(bool) toggle;

  const TraitSwitch(
    this.trait, {
    super.key,
    required this.storage,
    required this.icon,
    required this.toggle,
    required this.name,
  });

  @override
  build(context) {
    late final messages = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return [
      SwitchListTile(
        title: Text(trait is InheritedTrait ? name + messages.becauseOf : name),
        activeColor: colors.error,
        value: trait is OwnTrait,
        selected: trait != null,
        secondary: icon,
        onChanged: toggle,
      ),
      if (trait case InheritedTrait trait)
        ListTile(
          iconColor: colors.error,
          leading: const Icon(Icons.link),
          title: trait.heritage
              .map(storage.getPassportlessEntity)
              .nonNulls
              .map((entity) => entity.chip)
              .toList()
              .wrap,
        )
    ].column.card;
  }
}
