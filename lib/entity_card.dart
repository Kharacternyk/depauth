import 'package:flutter/material.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'entity_icon.dart';
import 'fractional_padding.dart';
import 'types.dart';

class EntityCard extends StatelessWidget {
  final EntityVertex entity;

  const EntityCard(this.entity, {super.key});

  @override
  build(context) {
    const padding = EdgeInsets.all(8);

    return FractionalPadding(
      childSizeFactor: 6,
      child: ArrowElement(
        id: entity.entity.name,
        targetIds: entity.dependencies.map((entity) => entity.name).toList(),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        sourceAnchor: Alignment.topCenter,
        targetAnchor: Alignment.bottomCenter,
        tipLength: 0,
        width: 4,
        child: Card(
          elevation: 10,
          margin: EdgeInsets.zero,
          shape: const Border(),
          child: Column(
            children: [
              Expanded(
                child: FittedBox(
                  child: Container(
                    padding: padding,
                    child: Text(entity.entity.name),
                  ),
                ),
              ),
              EntityIcon(
                entity.entity,
                padding: padding,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
