import 'package:flutter/material.dart';

import 'core/entity.dart';
import 'entity_chip.dart';
import 'entity_placeholder.dart';

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
    for (var y = minY; y <= maxY + 1; ++y) {
      final row = <Widget>[];
      for (var x = minX; x <= maxX + 1; ++x) {
        row.add(switch (entities[(x, y)]) {
          Entity entity => EntityChip<(int, int)>(
              entity,
              scale: scale,
              dragData: (x, y),
            ),
          null => EntityPlaceholder<(int, int)>(
              onDragAccepted: (point) => move((x, y), point),
              icon: switch ((x - maxX, y - maxY)) {
                (1, 1) => Icons.south_east,
                (_, 1) => Icons.south,
                (1, _) => Icons.east,
                _ => null,
              },
            ),
        });
      }
      rows.add(Expanded(child: Row(children: row)));
    }

    return Column(children: rows);
  }
}
