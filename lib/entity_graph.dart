import 'package:flutter/material.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'db.dart';
import 'entity_card.dart';
import 'entity_placeholder.dart';
import 'scaled_draggable.dart';
import 'types.dart';

class EntityGraph extends StatefulWidget {
  final double scale;

  const EntityGraph({required this.scale, super.key});

  @override
  createState() => _State();
}

class _State extends State<EntityGraph> {
  final Db db = Db();

  @override
  build(context) {
    return ValueListenableBuilder(
      valueListenable: db.boundaries,
      builder: (context, boundaries, child) {
        final rows = <Expanded>[];

        for (var y = boundaries.start.y - 1; y <= boundaries.end.y + 1; ++y) {
          final row = <Widget>[];

          for (var x = boundaries.start.x - 1; x <= boundaries.end.x + 1; ++x) {
            final position = Position(x, y);
            final entity = db.getEntity(position);

            row.add(
              ValueListenableBuilder(
                valueListenable: entity,
                builder: (context, entity, child) {
                  return switch (entity) {
                    EntityVertex entity => Expanded(
                        child: ScaledDraggable<Position>(
                          scale: widget.scale,
                          dragData: position,
                          child: EntityCard(
                            entity,
                          ),
                        ),
                      ),
                    null => EntityPlaceholder<Position>(
                        onDragAccepted: (oldPosition) =>
                            db.moveEntity(from: oldPosition, to: position),
                        icon: switch ((
                          (x - boundaries.end.x, y - boundaries.end.y),
                          (boundaries.start.x - x, boundaries.start.y - y)
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
                  };
                },
              ),
            );
          }

          rows.add(Expanded(child: Row(children: row)));
        }

        return ArrowContainer(child: Column(children: rows));
      },
    );
  }
}
