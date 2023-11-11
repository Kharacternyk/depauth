import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'core/boundaries.dart';
import 'core/position.dart';
import 'widget_extension.dart';

class EntityPlaceholder<DragDataType extends Object> extends StatelessWidget {
  final void Function(DragDataType) onDragAccepted;
  final Boundaries boundaries;
  final Position position;

  const EntityPlaceholder({
    required this.onDragAccepted,
    required this.boundaries,
    required this.position,
    super.key,
  });

  @override
  build(context) {
    final colors = Theme.of(context).colorScheme;
    final messages = AppLocalizations.of(context)!;
    final isSingleton = boundaries.start == boundaries.end;
    final Widget child;

    if (isSingleton) {
      child = Center(
        child: Text(
          messages.singletonPlaceholderTip,
          textAlign: TextAlign.center,
        ),
      ).pad(const EdgeInsets.all(8));
    } else {
      child = Icon(
        switch ((
          (position.x - boundaries.end.x, position.y - boundaries.end.y),
          (boundaries.start.x - position.x, boundaries.start.y - position.y)
        )) {
          ((0, 0), (0, 0)) => null,
          ((0, 0), _) => Icons.south_east,
          (_, (0, 0)) => Icons.north_west,
          ((_, 0), (0, _)) => Icons.south_west,
          ((0, _), (_, 0)) => Icons.north_east,
          ((_, 0), _) => Icons.south,
          ((0, _), _) => Icons.east,
          (_, (_, 0)) => Icons.north,
          (_, (0, _)) => Icons.west,
          _ => null,
        },
        color: colors.onPrimaryContainer,
      ).fit.grow;
    }

    return DragTarget(
      builder: (context, candidate, rejected) {
        return Ink(
          color: isSingleton && candidate.isEmpty
              ? Colors.transparent
              : colors.primaryContainer,
          child: child,
        ).hideIf(candidate.isEmpty && !isSingleton);
      },
      onAccept: onDragAccepted,
    );
  }
}
