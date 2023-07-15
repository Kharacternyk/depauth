import 'package:flutter/material.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'core/db.dart';
import 'core/entity.dart';
import 'core/entity_source.dart';
import 'core/entity_type.dart';
import 'core/position.dart';
import 'core/traversable_entity.dart';
import 'entity_card.dart';
import 'entity_placeholder.dart';
import 'scaled_draggable.dart';

class EntityGraph extends StatefulWidget {
  const EntityGraph({super.key});

  @override
  createState() => _State();
}

class _State extends State<EntityGraph> {
  final Db db = Db(
    entityDuplicatePrefix: ' (',
    entityDuplicateSuffix: ')',
  );

  @override
  dispose() {
    db.dispose();
    super.dispose();
  }

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
                          dragData: EntityFromPositionSource(position),
                          child: EntityCard(
                            entity,
                            deleteEntity: () {
                              db.deleteEntity(position);
                            },
                            changeEntity: (entity) {
                              db.changeEntity(position, entity);
                            },
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
                              db.createEntity(
                                position,
                                const Entity(
                                  'New Entity',
                                  EntityType.generic,
                                ),
                              );
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

        final column = Column(children: rows);

        return ListenableBuilder(
          listenable: db.dependencyChangeNotifier,
          builder: (context, child) => ArrowContainer(
            key: UniqueKey(),
            child: column,
          ),
        );
      },
    );
  }
}
