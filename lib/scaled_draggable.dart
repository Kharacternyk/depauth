import 'package:flutter/material.dart';

import 'late_widget.dart';
import 'viewer.dart';

class ScaledDraggable<DragDataType extends Object> extends StatelessWidget {
  final Widget child;
  final DragDataType dragData;
  final bool needsMaterial;

  const ScaledDraggable({
    required this.dragData,
    required this.child,
    this.needsMaterial = false,
    super.key,
  });

  @override
  build(context) {
    return Draggable(
      feedback: LateWidget(() {
        final renderBox = context.findRenderObject() as RenderBox;
        final child = needsMaterial
            ? Material(
                type: MaterialType.transparency,
                child: this.child,
              )
            : this.child;

        return Transform.scale(
          scale: switch (Scale.maybeOf(context)) {
            null => 1,
            Scale scale => scale.value
          },
          child: SizedBox.fromSize(
            size: renderBox.size,
            child: Opacity(
              opacity: 0.5,
              child: child,
            ),
          ),
        );
      }),
      data: dragData,
      childWhenDragging: const SizedBox.shrink(),
      child: child,
    );
  }
}
