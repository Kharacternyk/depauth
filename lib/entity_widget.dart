import 'package:flutter/material.dart';

import 'entity.dart';

class EntityWidget extends StatefulWidget {
  final Entity entity;

  const EntityWidget(this.entity, {super.key});

  @override
  createState() => _State(entity);
}

class _State extends State<EntityWidget> {
  Entity entity;

  _State(this.entity);

  @override
  build(BuildContext context) {
    final chip = Chip(
      avatar: Icon(switch (entity.type) {
        EntityType.hardwareKey => Icons.key,
        EntityType.webService => Icons.web,
      }),
      label: Text(entity.name),
    );

    final yOffset = Scaffold.of(context).appBarMaxHeight!;

    return Positioned(
      top: entity.y,
      left: entity.x,
      child: Draggable(
        feedback: Card(child: chip),
        childWhenDragging: const SizedBox.shrink(),
        onDragEnd: (drag) => setState(() {
          entity = Entity(
            type: entity.type,
            name: entity.name,
            x: drag.offset.dx,
            y: drag.offset.dy - yOffset,
          );
        }),
        child: chip,
      ),
    );
  }
}
