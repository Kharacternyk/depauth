import 'package:flutter/material.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'db.dart';
import 'entity_card.dart';
import 'entity_placeholder.dart';
import 'fractional_padding.dart';
import 'scaled_draggable.dart';

class EntityGraph extends StatelessWidget {
  final Db db;
  final void Function((int, int) source, (int, int) destination) move;
  final double scale;

  const EntityGraph(this.db,
      {required this.scale, required this.move, super.key});

  @override
  build(context) {
    final (minX, minY, maxX, maxY) = db.getMapCoordinates();

    final rows = <Expanded>[];
    for (var y = minY - 1; y <= maxY + 1; ++y) {
      final row = <Widget>[];
      for (var x = minX - 1; x <= maxX + 1; ++x) {
        final entity = db.getEntityNameAndDependenciesByCoordinates(x, y);

        row.add(switch (entity) {
          (String name, Set<String> dependencies) => Expanded(
              child: ScaledDraggable<(int, int)>(
                scale: scale,
                dragData: (x, y),
                child: EntityCard(name),
                wrapDragged: (child) =>
                    FractionalPadding(childSizeFactor: 6, child: child),
                wrapPlaced: (child) => FractionalPadding(
                  childSizeFactor: 6,
                  child: ArrowElement(
                    id: name,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    targetIds: dependencies.toList(),
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
