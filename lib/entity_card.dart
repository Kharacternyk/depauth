import 'package:flutter/material.dart';

import 'entity_icon.dart';
import 'types.dart';

class EntityCard extends StatelessWidget {
  final Entity entity;

  const EntityCard(this.entity, {super.key});

  @override
  build(context) {
    const padding = EdgeInsets.all(8);

    return Card(
      elevation: 10,
      margin: EdgeInsets.zero,
      shape: const Border(),
      child: Column(
        children: [
          Expanded(
            child: FittedBox(
              child: Container(
                padding: padding,
                child: Text(entity.name),
              ),
            ),
          ),
          EntityIcon(
            entity,
            padding: padding,
          ),
        ],
      ),
    );
  }
}
