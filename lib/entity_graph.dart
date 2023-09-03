import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'core/boundaries.dart';
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
    return (Boundaries boundaries) {
      final rows = <Widget>[];

      for (var y = boundaries.start.y; y <= boundaries.end.y; ++y) {
        final row = <Widget>[];

        for (var x = boundaries.start.x; x <= boundaries.end.x; ++x) {
          final position = Position(x, y);
          final listenableEntity = storage.getListenableEntity(position);

          row.add(
            (TraversableEntity? entity) {
              return switch (entity) {
                TraversableEntity entity => () {
                    return ScaledDraggable(
                      keepsSpace: false,
                      dragData: EntityTraveler(position, entity.identity),
                      child: EntityCard(
                        entity,
                        insight: storage.getEntityInsight(entity.identity),
                        onTap: () {
                          setEditablePosition(position);
                        },
                      ),
                    ).expand();
                  }.listen(storage.entityInsightNotifier),
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
                    boundaries: boundaries,
                    position: position,
                  ),
              };
            }.listen(listenableEntity).keyed(ValueKey(x)),
          );
        }

        rows.add(row.row.expand().keyed(ValueKey(y)));
      }

      return ArrowContainer(child: rows.column);
    }.listen(storage.boundaries).group;
  }
}
