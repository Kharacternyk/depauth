import 'package:flutter/material.dart';

import 'widget_extension.dart';

class EntityPlaceholder<DragDataType extends Object> extends StatelessWidget {
  final void Function(DragDataType) onDragAccepted;
  final Widget icon;

  const EntityPlaceholder({
    required this.onDragAccepted,
    required this.icon,
    super.key,
  });

  @override
  build(context) {
    return DragTarget(
      builder: (context, candidate, rejected) => Ink(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: icon.fit,
      ).hideIf(candidate.isEmpty),
      onAccept: onDragAccepted,
    ).expand();
  }
}
