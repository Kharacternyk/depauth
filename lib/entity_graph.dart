import 'package:flutter/material.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'core/db.dart';
import 'core/types.dart';
import 'entity_card.dart';
import 'entity_placeholder.dart';
import 'fractional_padding.dart';
import 'scaled_draggable.dart';

class EntityGraph extends StatelessWidget {
  final Db db;
  final void Function(String name, int x, int y) move;
  final double scale;

  const EntityGraph(this.db,
      {required this.scale, required this.move, super.key});

  @override
  build(context) {
    final (start: start, end: end) = db.getMapBoundaries();

    final rows = <Expanded>[];
    for (var y = start.y - 1; y <= end.y + 1; ++y) {
      final row = <Widget>[];
      for (var x = start.x - 1; x <= end.x + 1; ++x) {
        final entity = db.getEntityByPosition(x: x, y: y);

        row.add(switch (entity) {
          ({String name, Set<String> dependencyNames, EntityType type})
            entity =>
            Expanded(
              child: ScaledDraggable<String>(
                scale: scale,
                dragData: entity.name,
                child: EntityCard(name: entity.name, type: entity.type),
                wrapDragged: (child) =>
                    FractionalPadding(childSizeFactor: 6, child: child),
                wrapPlaced: (child) => FractionalPadding(
                  childSizeFactor: 6,
                  child: ArrowElement(
                    id: entity.name,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    targetIds: entity.dependencyNames.toList(),
                    sourceAnchor: Alignment.topCenter,
                    targetAnchor: Alignment.bottomCenter,
                    tipLength: 0,
                    width: 4,
                    child: child,
                  ),
                ),
              ),
            ),
          null => EntityPlaceholder<String>(
              onDragAccepted: (name) => move(name, x, y),
              icon: switch ((
                (x - end.x, y - end.y),
                (start.x - x, start.y - y)
              )) {
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
