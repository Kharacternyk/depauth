import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'core/entity.dart';
import 'core/storage.dart';
import 'core/trait.dart';
import 'entity_chip.dart';
import 'widget_extension.dart';

class TraitSwitch extends StatelessWidget {
  final Trait? trait;
  final String name;
  final Iterable<Entity> dependencies;
  final Widget icon;
  final void Function(bool) toggle;

  const TraitSwitch(
    this.trait, {
    super.key,
    required this.dependencies,
    required this.icon,
    required this.toggle,
    required this.name,
  });

  @override
  build(context) {
    final messages = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final heritage = switch (trait) {
      InheritedTrait trait => trait.heritage.toSet(),
      _ => const <Identity<Entity>>{},
    };
    final heritageChips = <Widget>[];

    for (final dependency in dependencies) {
      if (heritage.isEmpty) {
        break;
      }
      if (heritage.remove(dependency.identity)) {
        heritageChips.add(dependency.chip);
      }
    }

    return [
      SwitchListTile(
        title: heritageChips.isEmpty
            ? Text(name)
            : Text(name + messages.becauseOf),
        activeColor: colors.error,
        value: trait is OwnTrait,
        selected: trait != null,
        secondary: icon,
        onChanged: toggle,
      ),
      if (heritageChips.isNotEmpty)
        ListTile(
          iconColor: colors.error,
          leading: const Icon(Icons.link),
          title: heritageChips.wrap,
        )
    ].column.card;
  }
}
