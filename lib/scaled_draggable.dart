import 'package:flutter/material.dart';

import 'late_widget.dart';
import 'scale.dart';

class ScaledDraggable<DragDataType extends Object> extends StatelessWidget {
  final Widget child;
  final DragDataType dragData;
  final bool needsMaterial;
  final bool keepsSpace;

  const ScaledDraggable({
    required this.dragData,
    required this.child,
    this.needsMaterial = false,
    this.keepsSpace = true,
    super.key,
  });

  @override
  build(context) {
    return Draggable(
      feedback: LateWidget(() {
        final renderBox = context.findRenderObject() as RenderBox;

        return Transform.scale(
          scale: switch (Scale.maybeOf(context)) {
            null => 1,
            Scale scale => scale.value
          },
          child: SizedBox.fromSize(
            size: renderBox.size,
            child: Opacity(
              opacity: .5,
              child: needsMaterial
                  ? Material(
                      type: MaterialType.transparency,
                      child: child,
                    )
                  : child,
            ),
          ),
        );
      }),
      data: dragData,
      childWhenDragging: keepsSpace
          ? Visibility(
              maintainSize: true,
              maintainState: true,
              maintainAnimation: true,
              visible: false,
              child: child,
            )
          : const SizedBox.shrink(),
      child: child,
    );
  }
}
