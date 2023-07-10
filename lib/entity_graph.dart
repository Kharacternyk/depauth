import 'package:flutter/material.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'db.dart';
import 'entity_card.dart';
import 'entity_placeholder.dart';
import 'fractional_padding.dart';
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
    final (start, end) = db.getMapBoundaries();
    final rows = <Expanded>[];

    for (var y = start.y - 1; y <= end.y + 1; ++y) {
      final row = <Widget>[];

      for (var x = start.x - 1; x <= end.x + 1; ++x) {
        final position = Position(x, y);
        final id = db.getEntityId(position);
        final entity =
            switch (id) { EntityId id => db.getEntity(id), null => null };

        row.add(switch (entity) {
          Entity entity => Expanded(
              child: ScaledDraggable<EntityId>(
                scale: widget.scale,
                dragData: id!,
                child: EntityCard(name: entity.name, type: entity.type),
                wrapDragged: (child) =>
                    FractionalPadding(childSizeFactor: 6, child: child),
                wrapPlaced: (child) => FractionalPadding(
                  childSizeFactor: 6,
                  child: ArrowElement(
                    id: id.value.toString(),
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    sourceAnchor: Alignment.topCenter,
                    targetAnchor: Alignment.bottomCenter,
                    targetIds: db
                        .getDependencies(id)
                        .map((id) => id.value.toString())
                        .toList(),
                    tipLength: 0,
                    width: 4,
                    child: child,
                  ),
                ),
              ),
            ),
          null => EntityPlaceholder<EntityId>(
              onDragAccepted: (id) =>
                  setState(() => db.setEntityPosition(id, position)),
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
