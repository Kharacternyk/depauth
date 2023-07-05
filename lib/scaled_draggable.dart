import 'package:flutter/material.dart';

class ScaledDraggable<DragDataType extends Object> extends StatelessWidget {
  final Widget child;
  final double scale;
  final DragDataType dragData;
  final Widget Function(Widget)? wrapPlaced;
  final Widget Function(Widget)? wrapDragged;

  const ScaledDraggable({
    required this.dragData,
    required this.child,
    required this.scale,
    this.wrapPlaced,
    this.wrapDragged,
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
            child: switch (wrapDragged) {
              null => child,
              Widget Function(Widget) f => f(child),
            },
          ),
        );
      }),
      data: dragData,
      childWhenDragging: const SizedBox.shrink(),
      child: switch (wrapPlaced) {
        null => child,
        Widget Function(Widget) f => f(child),
      },
    );
  }
}
