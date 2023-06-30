import 'package:flutter/material.dart';

import 'entity.dart';

class EntityChip extends StatelessWidget {
  final Entity entity;
  final double scale;

  const EntityChip(this.entity, {required this.scale, super.key});

  @override
  build(context) {
    final chip = Chip(
      avatar: Icon(switch (entity.type) {
        EntityType.hardwareKey => Icons.key,
        EntityType.webService => Icons.web,
      }),
      label: Text(entity.name),
    );

    return Draggable(
      feedback: Transform.scale(
        scale: scale,
        child: Card(child: chip),
      ),
      childWhenDragging: const SizedBox.shrink(),
      child: chip,
    );
  }
}
