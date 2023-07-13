import 'package:flutter/material.dart';

class ScaledDraggable<DragDataType extends Object> extends StatelessWidget {
  final Widget child;
  final DragDataType dragData;
  final double scale;

  const ScaledDraggable({
    required this.dragData,
    required this.child,
    this.scale = 1,
    super.key,
  });

  @override
  build(context) {
    return Draggable(
      feedback: LayoutBuilder(builder: (feedbackContext, constraints) {
        final renderBox = context.findRenderObject() as RenderBox;
        return Transform.scale(
          scale: scale,
          child: SizedBox.fromSize(
            size: renderBox.size,
            child: child,
          ),
        );
      }),
      data: dragData,
      childWhenDragging: const SizedBox.shrink(),
      child: child,
    );
  }
}
