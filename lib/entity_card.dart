import 'package:flutter/material.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'core/traversable_entity.dart';
import 'entity_icon.dart';
import 'entity_theme.dart';
import 'scaled_line.dart';
import 'widget_extension.dart';

class EntityCard extends StatelessWidget {
  final TraversableEntity entity;
  final VoidCallback onTap;
  final bool hasLostFactor;

  const EntityCard(
    this.entity, {
    required this.onTap,
    required this.hasLostFactor,
    super.key,
  });

  @override
  build(context) {
    const padding = EdgeInsets.all(8);
    final colors = Theme.of(context).colorScheme;
    final dependencyIcons = <Widget>[];

    for (final factor in entity.factors) {
      for (final dependency in factor.dependencies) {
        dependencyIcons.add(
          ScaledLine(
            name: '${factor.identity}:${dependency.identity}',
            color: EntityTheme(dependency.type).arrow.withOpacity(0.5),
            targetName: dependency.identity.toString(),
            child: EntityIcon(
              dependency.type,
              padding: padding,
            ),
          ).expand(key: ValueKey((factor.identity, dependency.identity))),
        );
      }
      dependencyIcons.add(
        const Icon(Icons.add).pad(padding).fit().grow().expand(),
      );
    }

    if (dependencyIcons.isNotEmpty) {
      dependencyIcons.removeLast();
    }

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
                if (entity.factors.isNotEmpty) dependencyIcons.toRow().expand(),
                Text(entity.name).pad(padding).fit().expand(),
                EntityIcon(
                  entity.type,
                  padding: padding,
                ).expand(),
              ].toColumn(),
            ),
          ),
        ).expand(flex: 6),
        [
          Spacer(flex: entity.lost || hasLostFactor ? 1 : 2),
          entity.lost || hasLostFactor || entity.compromised
              ? Material(
                  color: colors.error,
                  child: [
                    if (entity.lost || hasLostFactor)
                      Icon(
                        Icons.not_listed_location,
                        color: colors.onError,
                      ).fit().grow().expand(),
                    if (entity.compromised)
                      Icon(
                        Icons.report,
                        color: colors.onError,
                      ).fit().grow().expand(),
                  ].toColumn(),
                ).expand(
                  flex: (entity.lost || hasLostFactor) && entity.compromised
                      ? 2
                      : 1,
                )
              : const SizedBox.shrink(),
          Spacer(flex: entity.compromised ? 1 : 2),
        ].toColumn().expand(),
      ].toRow().expand(flex: 6),
      const Spacer(),
    ].toColumn();
  }
}
