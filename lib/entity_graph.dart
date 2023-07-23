import 'package:flutter/material.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'core/db.dart';
import 'core/entity.dart';
import 'core/entity_source.dart';
import 'core/entity_type.dart';
import 'core/factor.dart';
import 'core/position.dart';
import 'core/traversable_entity.dart';
import 'entity_card.dart';
import 'entity_form.dart';
import 'entity_placeholder.dart';
import 'scaled_draggable.dart';

class EntityGraph extends StatefulWidget {
  final String dbPath;
  final void Function(Widget?) setDrawer;

  const EntityGraph(this.dbPath, {required this.setDrawer, super.key});

  @override
  createState() => _State();
}

class _State extends State<EntityGraph> {
  late final Db db = Db(
    widget.dbPath,
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
            final listenableEntity = db.getEntity(position);

            row.add(
              ValueListenableBuilder(
                key: ValueKey(x),
                valueListenable: listenableEntity,
                builder: (context, entity, child) {
                  return switch (entity) {
                    TraversableEntity entity => Expanded(
                        child: ScaledDraggable(
                          dragData: EntityFromPositionSource(position),
                          child: EntityCard(
                            entity,
                            onTap: () {
                              widget.setDrawer(
                                ValueListenableBuilder(
                                  valueListenable: listenableEntity,
                                  builder: (context, entity, child) {
                                    return switch (entity) {
                                      TraversableEntity entity => EntityForm(
                                          entity,
                                          closeItself: () {
                                            widget.setDrawer(null);
                                          },
                                          getPossibleDependencies:
                                              db.getPossibleDependencies,
                                          deleteEntity: () {
                                            db.deleteEntity(position);
                                          },
                                          changeEntity: (entity) {
                                            db.changeEntity(position, entity);
                                          },
                                          addDependency: (
                                            Id<Factor> factorId,
                                            Id<Entity> entityId,
                                          ) {
                                            db.addDependency(
                                              position,
                                              factorId,
                                              entityId,
                                            );
                                          },
                                          deleteDependency: (
                                            Id<Factor> factorId,
                                            Id<Entity> entityId,
                                          ) {
                                            db.deleteDependency(
                                              position,
                                              factorId,
                                              entityId,
                                            );
                                          },
                                        ),
                                      null => const SizedBox.shrink(),
                                    };
                                  },
                                ),
                              );
                              Scaffold.of(context).openEndDrawer();
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

          rows.add(Expanded(key: ValueKey(y), child: Row(children: row)));
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
