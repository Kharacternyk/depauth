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
    return Expanded(
      child: DragTarget(
        builder: (context, candidate, rejected) => SizedBox.expand(
          child: candidate.isNotEmpty
              ? Ink(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: icon.fit(),
                )
              : null,
        ),
        onAccept: onDragAccepted,
      ),
    );
  }
}
