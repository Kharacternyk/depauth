import 'package:flutter/material.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'entity_icon.dart';
import 'entity_theme.dart';
import 'fractional_padding.dart';
import 'types.dart';

class EntityCard extends StatelessWidget {
  final EntityVertex entity;
  final double arrowScale;

  const EntityCard(this.entity, {this.arrowScale = 1, super.key});

  @override
  build(context) {
    const padding = EdgeInsets.all(8);
    return FractionalPadding(
      childSizeFactor: 6,
      child: ArrowElement(
        id: entity.entity.name,
        child: Card(
          elevation: 10,
          margin: EdgeInsets.zero,
          shape: const Border(),
          child: Column(
            children: [
              if (entity.dependencies.isNotEmpty)
                Expanded(
                  child: Row(
                    children: entity.dependencies
                        .expand(
                          (dependencyGroup) => dependencyGroup.map(
                            (dependency) => Expanded(
                              child: ArrowElement(
                                id: '${dependency.name}^${entity.entity.name}',
                                color: EntityTheme(dependency)
                                    .arrow
                                    .withOpacity(0.5),
                                sourceAnchor: Alignment.topCenter,
                                targetAnchor: Alignment.bottomCenter,
                                tipLength: 0,
                                width: 4 * arrowScale,
                                targetId: dependency.name,
                                child: EntityIcon(
                                  dependency,
                                  padding: padding,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              Expanded(
                child: FittedBox(
                  child: Container(
                    padding: padding,
                    child: Text(entity.entity.name),
                  ),
                ),
              ),
              Expanded(
                child: EntityIcon(
                  entity.entity,
                  padding: padding,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
