import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'boundary_icon.dart';
import 'core/insightful_storage.dart';
import 'core/position.dart';
import 'core/traveler.dart';
import 'core/traversable_entity.dart';
import 'entity_card.dart';
import 'entity_placeholder.dart';
import 'scaled_draggable.dart';
import 'widget_extension.dart';

class EntityGraph extends StatelessWidget {
  final InsightfulStorage storage;
  final void Function(Position) setEditablePosition;

  const EntityGraph(
    this.storage, {
    required this.setEditablePosition,
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
                  return switch (entity) {
                    TraversableEntity entity => Expanded(
                        child: ListenableBuilder(
                          listenable: storage.insightNotifier,
                          builder: (context, child) => ScaledDraggable(
                            keepsSpace: false,
                            dragData: EntityTraveler(position, entity.identity),
                            child: EntityCard(
                              entity,
                              insight: storage.getInsight(entity.identity),
                              onTap: () {
                                setEditablePosition(position);
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
                              setEditablePosition(position);
                            case CreationTraveler _:
                              storage.createEntity(
                                position,
                                AppLocalizations.of(context)!.newEntity,
                              );
                              setEditablePosition(position);
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
