import 'package:flutter/material.dart';

class EntityPlaceholder<DragDataType extends Object> extends StatelessWidget {
  final void Function(DragDataType) onDragAccepted;
  final IconData? icon;

  const EntityPlaceholder({required this.onDragAccepted, this.icon, super.key});

  @override
  build(context) {
    return Expanded(
      child: DragTarget(
        builder: (context, candidate, rejected) => SizedBox(
          height: double.infinity,
          child: candidate.isNotEmpty
              ? Card(
                  elevation: 20,
                  child: icon != null ? Icon(icon) : null,
                )
              : null,
        ),
        onAccept: onDragAccepted,
      ),
    );
  }
}
