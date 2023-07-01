import 'package:flutter/material.dart';

import 'core/entity.dart';

class EntityChip<DragDataType extends Object> extends StatelessWidget {
  final Entity entity;
  final double scale;
  final DragDataType dragData;

  const EntityChip(this.entity,
      {required this.dragData, required this.scale, super.key});

  @override
  build(context) {
    final chip = Chip(
      avatar: Icon(switch (entity.type) {
        EntityType.hardwareKey => Icons.key,
        EntityType.webService => Icons.web,
        EntityType.person => Icons.person
      }),
      label: Text(entity.name),
    );

    return Expanded(
      child: Draggable(
        feedback: Card(child: chip),
        childWhenDragging: const SizedBox.shrink(),
        data: dragData,
        child: FittedBox(child: chip),
      ),
    );
  }
}
