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
    final dependencyIcons = <Widget>[];

    for (final group in entity.dependencies) {
      for (final dependency in group) {
        dependencyIcons.add(
          Expanded(
            child: ArrowElement(
              id: '${dependency.name}^${entity.entity.name}',
              color: EntityTheme(dependency).arrow.withOpacity(0.5),
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

    return FractionalPadding(
      childSizeFactor: 6,
      child: ArrowElement(
        id: entity.entity.name,
        child: Card(
          elevation: 10,
          margin: EdgeInsets.zero,
          shape: const Border(),
          child: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    children: [
                      SimpleDialogOption(
                        child: TextField(
                          controller: TextEditingController(
                            text: entity.entity.name,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            child: Column(
              children: [
                if (entity.dependencies.isNotEmpty)
                  Expanded(
                    child: Row(
                      children: dependencyIcons,
                    ),
                  ),
                Expanded(
                  child: FittedBox(
                    child: Padding(
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
      ),
    );
  }
}
