import 'package:flutter/material.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'core/entity.dart';

class EntityChip<DragDataType extends Object> extends StatelessWidget {
  final Entity entity;
  final double scale;
  final DragDataType dragData;

  const EntityChip(this.entity,
      {required this.dragData, required this.scale, super.key});

  @override
  build(context) {
    final body = Padding(
      padding: const EdgeInsets.all(12),
      child: ArrowElement(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        id: entity.name,
        targetIds: entity.dependsOn.toList(),
        sourceAnchor: Alignment.bottomCenter,
        targetAnchor: Alignment.topCenter,
        tipLength: 0,
        child: FittedBox(
          child: FloatingActionButton.extended(
            icon: Icon(switch (entity.type) {
              EntityType.hardwareKey => Icons.key,
              EntityType.webService => Icons.web,
              EntityType.person => Icons.person
            }),
            label: Text(entity.name),
            onPressed: () {},
          ),
        ),
      ),
    );

    return Expanded(
      child: Draggable(
        feedback: LayoutBuilder(builder: (feedbackContext, constraints) {
          final renderBox = context.findRenderObject() as RenderBox;
          return Transform.scale(
            scale: scale,
            child: SizedBox.fromSize(
              size: renderBox.size,
              child: body,
            ),
          );
        }),
        childWhenDragging: const SizedBox.shrink(),
        data: dragData,
        child: body,
      ),
    );
  }
}
