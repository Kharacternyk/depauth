import 'package:flutter/material.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'boundary_icon.dart';
import 'core/entity.dart';
import 'core/factor.dart';
import 'core/insightful_storage.dart';
import 'core/position.dart';
import 'core/storage.dart';
import 'core/traveler.dart';
import 'core/traversable_entity.dart';
import 'entity_card.dart';
import 'entity_form.dart';
import 'entity_placeholder.dart';
import 'scaled_draggable.dart';
import 'widget_extension.dart';

class EntityGraph extends StatelessWidget {
  final InsightfulStorage storage;
  final void Function(Widget) setSideBar;
  final Widget defaultSideBar;

  const EntityGraph(
    this.storage, {
    required this.setSideBar,
    required this.defaultSideBar,
    super.key,
  });

  @override
  build(context) {
    return ValueListenableBuilder(
      valueListenable: storage.boundaries,
      builder: (context, boundaries, child) {
        final rows = <Expanded>[];

        for (var y = boundaries.start.y; y <= boundaries.end.y; ++y) {
          final row = <Widget>[];

          for (var x = boundaries.start.x; x <= boundaries.end.x; ++x) {
            final position = Position(x, y);
            final listenableEntity = storage.getListenableEntity(position);

            row.add(
              ValueListenableBuilder(
                key: ValueKey(x),
                valueListenable: listenableEntity,
                builder: (context, entity, child) {
                  late final entityForm = ValueListenableBuilder(
                    valueListenable: listenableEntity,
                    builder: (context, entity, child) {
                      return switch (entity) {
                        TraversableEntity entity => ListenableBuilder(
                            listenable: storage.traitInsightNotifier,
                            builder: (child, context) => EntityForm(
                              entity,
                              position: position,
                              hasLostFactor:
                                  storage.hasLostFactor(entity.identity),
                              areAllFactorsCompromised: storage
                                  .areAllFactorsCompromised(entity.identity),
                              changeName: (name) {
                                storage.changeName(position, name);
                              },
                              changeType: (type) {
                                storage.changeType(position, type);
                              },
                              toggleLost: (value) {
                                storage.toggleLost(position, value);
                              },
                              toggleCompromised: (value) {
                                storage.toggleCompromised(position, value);
                              },
                              addDependency: (
                                Identity<Factor> factor,
                                Identity<Entity> entity,
                              ) {
                                storage.addDependency(
                                  position,
                                  factor,
                                  entity,
                                );
                              },
                              removeDependency: (
                                Identity<Factor> factor,
                                Identity<Entity> entity,
                              ) {
                                storage.removeDependency(
                                  position,
                                  factor,
                                  entity,
                                );
                              },
                              addFactor: () {
                                storage.addFactor(position, entity.identity);
                              },
                            ),
                          ),
                        null => defaultSideBar,
                      };
                    },
                  );

                  return switch (entity) {
                    TraversableEntity entity => Expanded(
                        child: ListenableBuilder(
                          listenable: storage.traitInsightNotifier,
                          builder: (context, child) => ScaledDraggable(
                            keepsSpace: false,
                            dragData: EntityTraveler(position, entity.identity),
                            child: EntityCard(
                              entity,
                              hasLostFactor:
                                  storage.hasLostFactor(entity.identity),
                              areAllFactorsCompromised: storage
                                  .areAllFactorsCompromised(entity.identity),
                              onTap: () {
                                setSideBar(entityForm);
                              },
                            ),
                          ),
                        ),
                      ),
                    null => EntityPlaceholder<GrabbableTraveler>(
                        onDragAccepted: (source) {
                          switch (source) {
                            case EntityTraveler source:
                              storage.moveEntity(
                                  from: source.position, to: position);
                              setSideBar(defaultSideBar);
                            case CreationTraveler _:
                              storage.createEntity(position, 'New Entity');
                              setSideBar(entityForm);
                          }
                        },
                        icon: BoundaryIcon(boundaries, position),
                      ),
                  };
                },
              ),
            );
          }

          rows.add(Expanded(key: ValueKey(y), child: Row(children: row)));
        }

        final graph = IconTheme(
          data: IconThemeData(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          child: rows.toColumn(),
        );

        return ListenableBuilder(
          listenable: storage.dependencyChangeNotifier,
          builder: (context, child) => ArrowContainer(
            key: UniqueKey(),
            child: graph,
          ),
        );
      },
    );
  }
}
