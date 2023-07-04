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
    const padding = EdgeInsets.all(8);

    final body = Column(
      children: [
        const Spacer(),
        Expanded(
          flex: 6,
          child: ArrowElement(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            id: entity.name,
            targetIds: entity.dependsOn.toList(),
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
