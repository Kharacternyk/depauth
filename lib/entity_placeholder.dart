import 'package:flutter/material.dart';

class EntityPlaceholder<DragDataType extends Object> extends StatelessWidget {
  final void Function(DragDataType) onDragAccepted;

  const EntityPlaceholder({required this.onDragAccepted, super.key});

  @override
  build(context) {
    return Expanded(
      child: DragTarget(
        builder: (context, candidate, rejected) => const Icon(Icons.add),
        onAccept: onDragAccepted,
      ),
    );
  }
}
