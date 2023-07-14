import 'package:flutter/material.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'core/db.dart';
import 'core/entity_source.dart';
import 'core/position.dart';
import 'core/traversable_entity.dart';
import 'entity_card.dart';
import 'entity_placeholder.dart';
import 'scaled_draggable.dart';

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

        for (var y = boundaries.start.y; y <= boundaries.end.y; ++y) {
          final row = <Widget>[];

          for (var x = boundaries.start.x; x <= boundaries.end.x; ++x) {
            final position = Position(x, y);
            final entity = db.getEntity(position);

            row.add(
              ValueListenableBuilder(
                valueListenable: entity,
                builder: (context, entity, child) {
                  return switch (entity) {
                    TraversableEntity entity => Expanded(
                        child: ScaledDraggable(
                          scale: widget.scale,
                          dragData: EntityFromPositionSource(position),
                          child: EntityCard(
                            entity,
                            arrowScale: 1 / widget.scale,
                            onDelete: () => db.deleteEntity(position),
                          ),
                        ),
                      ),
                    null => EntityPlaceholder<EntitySource>(
                        onDragAccepted: (source) {
                          switch (source) {
                            case EntityFromPositionSource source:
                              db.moveEntity(
                                  from: source.position, to: position);
                            case NewEntitySource _:
                              db.createEntity(position);
                          }
                        },
                        icon: switch ((
                          (x - boundaries.end.x, y - boundaries.end.y),
                          (boundaries.start.x - x, boundaries.start.y - y)
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
