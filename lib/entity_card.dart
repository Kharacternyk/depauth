import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'core/entity_insight.dart';
import 'core/traversable_entity.dart';
import 'entity_icon.dart';
import 'entity_theme.dart';
import 'scaled_line.dart';
import 'widget_extension.dart';

class EntityCard extends StatelessWidget {
  final TraversableEntity entity;
  final VoidCallback onTap;
  final EntityInsight insight;

  const EntityCard(
    this.entity, {
    required this.onTap,
    required this.insight,
    super.key,
  });

  @override
  build(context) {
    const padding = EdgeInsets.all(8);
    final colors = Theme.of(context).colorScheme;
    final messages = AppLocalizations.of(context)!;
    final dependencyIcons = <Widget>[];

    for (final factor in entity.factors) {
      for (final dependency in factor.dependencies) {
        dependencyIcons.add(
          ScaledLine(
            name: [
              factor.identity,
              dependency.identity,
            ].join(messages.arrowIdentitySeparator),
            color: EntityTheme(dependency.type).primary.withOpacity(0.5),
            targetName: dependency.identity.toString(),
            child: EntityIcon(
              dependency.type,
              padding: padding,
            ),
          ).expand().keyed(ValueKey((factor.identity, dependency.identity))),
        );
      }
      dependencyIcons.add(
        const Icon(Icons.add).pad(padding).fit.grow.expand(),
      );
    }

    if (dependencyIcons.isNotEmpty) {
      dependencyIcons.removeLast();
    }

    final lost = insight.hasLostFactor || entity.lost;
    final compromised = insight.areAllFactorsCompromised || entity.compromised;

    return [
      const Spacer(),
      [
        const Spacer(),
        ArrowElement(
          id: entity.identity.toString(),
          child: Card(
            elevation: 10,
            margin: EdgeInsets.zero,
            shape: const Border(),
            child: InkWell(
              onTap: onTap,
              child: [
                if (entity.factors.isNotEmpty) dependencyIcons.row.expand(),
                Text(entity.name).pad(padding).fit.expand(),
                EntityIcon(
                  entity.type,
                  padding: padding,
                ).expand(),
              ].column,
            ),
          ),
        ).expand(6),
        [
          Spacer(flex: lost ? 1 : 2),
          lost || compromised
              ? Material(
                  color: colors.error,
                  child: [
                    if (lost)
                      Icon(
                        Icons.not_listed_location,
                        color: colors.onError,
                      ).fit.grow.expand(),
                    if (compromised)
                      Icon(
                        Icons.report,
                        color: colors.onError,
                      ).fit.grow.expand(),
                  ].column,
                ).expand(lost && compromised ? 2 : 1)
              : const SizedBox.shrink(),
          Spacer(flex: compromised ? 1 : 2),
        ].column.expand(),
      ].row.expand(6),
      const Spacer(),
    ].column;
  }
}
