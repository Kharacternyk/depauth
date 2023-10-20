import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'core/entity.dart';
import 'core/interleave.dart';
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
    final heritage = switch (trait) {
      InheritedTrait trait => trait.heritage.toSet(),
      _ => const <Identity<Entity>>{},
    };
    final heritageChips = <InlineSpan>[];

    for (final dependency in dependencies) {
      if (heritage.isEmpty) {
        break;
      }
      if (heritage.remove(dependency.identity)) {
        heritageChips.add(
          WidgetSpan(
            child: dependency.chip,
            alignment: PlaceholderAlignment.middle,
          ),
        );
      }
    }

    late final and = TextSpan(text: messages.paddedAnd);

    return SwitchListTile(
      title: heritageChips.isEmpty
          ? Text(name)
          : Text.rich(
              TextSpan(
                text: name + messages.because,
                children: [
                  ...heritageChips.interleave(and),
                  TextSpan(
                    text: heritageChips.length > 1
                        ? messages.arePeriod
                        : messages.isPeriod,
                  ),
                ],
              ),
            ),
      activeColor: Theme.of(context).colorScheme.error,
      value: trait is OwnTrait,
      selected: trait != null,
      secondary: icon,
      onChanged: toggle,
    ).card;
  }
}
