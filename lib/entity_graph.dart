import 'package:flutter/material.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'core/db.dart';
import 'core/entity.dart';
import 'core/entity_type.dart';
import 'core/factor.dart';
import 'core/position.dart';
import 'core/traveler.dart';
import 'core/traversable_entity.dart';
import 'entity_card.dart';
import 'entity_form.dart';
import 'entity_placeholder.dart';
import 'scaled_draggable.dart';

class EntityGraph extends StatelessWidget {
  final Db db;
  final void Function(Widget) setSideBar;
  final Widget defaultSideBar;

  const EntityGraph(
    this.db, {
    required this.setSideBar,
    required this.defaultSideBar,
    super.key,
  });

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
                  late final entityForm = ValueListenableBuilder(
                    valueListenable: listenableEntity,
                    builder: (context, entity, child) {
                      return switch (entity) {
                        TraversableEntity entity => EntityForm(
                            entity,
                            position: position,
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
                            removeDependency: (
                              Id<Factor> factorId,
                              Id<Entity> entityId,
                            ) {
                              db.removeDependency(
                                position,
                                factorId,
                                entityId,
                              );
                            },
                            addFactor: () {
                              db.addFactor(position, entity.id);
                            },
                          ),
                        null => defaultSideBar,
                      };
                    },
                  );

                  return switch (entity) {
                    TraversableEntity entity => Expanded(
                        child: ScaledDraggable(
                          keepsSpace: false,
                          dragData: EntityTraveler(position, entity.id),
                          child: EntityCard(
                            entity,
                            onTap: () {
                              setSideBar(entityForm);
                            },
                          ),
                        ),
                      ),
                    null => EntityPlaceholder<GrabbableTraveler>(
                        onDragAccepted: (source) {
                          switch (source) {
                            case EntityTraveler source:
                              db.moveEntity(
                                  from: source.position, to: position);
                              setSideBar(defaultSideBar);
                            case CreationTraveler _:
                              db.createEntity(
                                position,
                                const Entity(
                                  'New Entity',
                                  EntityType.generic,
                                ),
                              );
                              setSideBar(entityForm);
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
