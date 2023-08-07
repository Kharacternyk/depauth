import 'package:flutter/material.dart';

class EntityPlaceholder<DragDataType extends Object> extends StatelessWidget {
  final void Function(DragDataType) onDragAccepted;
  final IconData? icon;

  const EntityPlaceholder({required this.onDragAccepted, this.icon, super.key});

  @override
  build(context) {
    return Expanded(
      child: DragTarget(
        builder: (context, candidate, rejected) => SizedBox.expand(
          child: candidate.isNotEmpty
              ? Ink(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: icon != null
                      ? FittedBox(
                          child: Icon(
                            icon,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                        )
                      : null,
                )
              : null,
        ),
        onAccept: onDragAccepted,
      ),
    );
  }
}
