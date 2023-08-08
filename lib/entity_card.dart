import 'package:flutter/material.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'core/traversable_entity.dart';
import 'entity_icon.dart';
import 'entity_theme.dart';
import 'scaled_line.dart';

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
          Expanded(
            key: ValueKey((factor.identity, dependency.identity)),
            child: ScaledLine(
              name: '${factor.identity}:${dependency.identity}',
              color: EntityTheme(dependency.type).arrow.withOpacity(0.5),
              targetName: dependency.identity.toString(),
              child: EntityIcon(
                dependency.type,
                padding: padding,
              ),
            ),
          ),
        );
      }
      dependencyIcons.add(
        const Expanded(
          child: Column(
            children: [
              Expanded(
                child: FittedBox(
                  child: Padding(
                    padding: padding,
                    child: Icon(Icons.add),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (dependencyIcons.isNotEmpty) {
      dependencyIcons.removeLast();
    }

    return Column(
      children: [
        const Spacer(),
        Expanded(
          flex: 6,
          child: Row(
            children: [
              const Spacer(),
              Expanded(
                flex: 6,
                child: ArrowElement(
                  id: entity.identity.toString(),
                  child: Card(
                    elevation: 10,
                    margin: EdgeInsets.zero,
                    shape: const Border(),
                    child: InkWell(
                      onTap: onTap,
                      child: Column(
                        children: [
                          if (entity.factors.isNotEmpty)
                            Expanded(
                              child: Row(
                                children: dependencyIcons,
                              ),
                            ),
                          Expanded(
                            child: FittedBox(
                              child: Padding(
                                padding: padding,
                                child: Text(entity.name),
                              ),
                            ),
                          ),
                          Expanded(
                            child: EntityIcon(
                              entity.type,
                              padding: padding,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Spacer(),
                    Expanded(
                      child: Material(
                        color: hasLostFactor || entity.lost
                            ? colors.primary
                            : null,
                        child: SizedBox.expand(
                          child: hasLostFactor || entity.lost
                              ? FittedBox(
                                  child: Icon(
                                    Icons.not_listed_location,
                                    color: colors.onPrimary,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Material(
                        color: entity.compromised ? colors.error : null,
                        child: SizedBox.expand(
                          child: entity.compromised
                              ? FittedBox(
                                  child: Icon(
                                    Icons.report,
                                    color: colors.onError,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
