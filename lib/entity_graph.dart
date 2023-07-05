import 'package:flutter/material.dart';

import 'core/entity.dart';
import 'entity_card.dart';
import 'entity_placeholder.dart';
import 'fractional_padding.dart';
import 'scaled_draggable.dart';
import 'vendor/widget_arrows.dart';

class EntityGraph extends StatelessWidget {
  final Map<(int, int), Entity> entities;
  final void Function((int, int) source, (int, int) destination) move;
  final double scale;

  const EntityGraph(this.entities,
      {required this.scale, required this.move, super.key});

  @override
  build(context) {
    var min = entities.keys.firstOrNull ?? (0, 0);
    var max = min;

    for (final (x, y) in entities.keys) {
      final (minX, minY) = min;
      final (maxX, maxY) = max;
      min = (x < minX ? x : minX, y < minY ? y : minY);
      max = (x > maxX ? x : maxX, y > maxY ? y : maxY);
    }

    final (minX, minY) = min;
    final (maxX, maxY) = max;

    final rows = <Expanded>[];
    for (var y = minY - 1; y <= maxY + 1; ++y) {
      final row = <Widget>[];
      for (var x = minX - 1; x <= maxX + 1; ++x) {
        row.add(switch (entities[(x, y)]) {
          Entity entity => Expanded(
              child: ScaledDraggable<(int, int)>(
                scale: scale,
                dragData: (x, y),
                child: EntityCard(entity),
                wrapPlaced: (child) => FractionalPadding(
                  childSizeFactor: 6,
                  child: ArrowElement(
                    id: entity.name,
                    targetIds: entity.dependsOn.map((key, value) => MapEntry(
                        key,
                        Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(value.toDouble() * 0.8))),
                    sourceAnchor: Alignment.topCenter,
                    targetAnchor: Alignment.bottomCenter,
                    tipLength: 0,
                    width: 4,
                    child: child,
                  ),
                ),
              ),
            ),
          null => EntityPlaceholder<(int, int)>(
              onDragAccepted: (point) => move((x, y), point),
              icon: switch (((x - maxX, y - maxY), (minX - x, minY - y))) {
                ((1, 1), _) => Icons.south_east,
                (_, (1, 1)) => Icons.north_west,
                ((_, 1), (1, _)) => Icons.south_west,
                ((1, _), (_, 1)) => Icons.north_east,
                ((_, 1), _) => Icons.south,
                ((1, _), _) => Icons.east,
                (_, (_, 1)) => Icons.north,
                (_, (1, _)) => Icons.west,
                _ => null,
              },
            ),
        });
      }
      rows.add(Expanded(child: Row(children: row)));
    }

    return ArrowContainer(child: Column(children: rows));
  }
}
