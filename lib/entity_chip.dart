import 'package:flutter/material.dart';

import 'core/entity.dart';
import 'vendor/widget_arrows.dart';

class EntityChip extends StatelessWidget {
  final Entity entity;

  const EntityChip(this.entity, {super.key});

  @override
  build(context) {
    const padding = EdgeInsets.all(8);

    return Column(
      children: [
        const Spacer(),
        Expanded(
          flex: 6,
          child: ArrowElement(
            id: entity.name,
            targetIds: entity.dependsOn.map((key, value) => MapEntry(
                key,
                Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(value.toDouble()))),
            sourceAnchor: Alignment.topCenter,
            targetAnchor: Alignment.bottomCenter,
            tipLength: 0,
            width: 4,
            child: Column(
              children: [
                Expanded(
                  child: FittedBox(
                    child: CircleAvatar(
                      child: Container(
                        padding: padding,
                        child: Icon(switch (entity.type) {
                          EntityType.hardwareKey => Icons.key,
                          EntityType.webService => Icons.web,
                          EntityType.person => Icons.person
                        }),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: FittedBox(
                      child: Container(
                        padding: padding,
                        child: Text(entity.name),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
