import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'core/boundaries.dart';
import 'core/edit_subject.dart';
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
  final ValueNotifier<EditSubject> editSubject;

  const EntityGraph(
    this.storage, {
    required this.editSubject,
    super.key,
  });

  @override
  build(context) {
    return ArrowContainer(
      child: (Boundaries boundaries) {
        final rows = <Widget>[];

        for (var y = boundaries.start.y; y <= boundaries.end.y; ++y) {
          final cells = <Widget>[];

          for (var x = boundaries.start.x; x <= boundaries.end.x; ++x) {
            final position = Position(x, y);
            final listenableEntity = storage.getListenableEntity(position);
            final cell = (TraversableEntity? entity) {
              return switch (entity) {
                TraversableEntity entity => ScaledDraggable(
                    keepsSpace: false,
                    dragData: EntityTraveler(entity.passport),
                    child: EntityCard(
                      entity,
                      insightOrigin: storage,
                      editSubject: editSubject,
                    ).boundary,
                  ),
                null => EntityPlaceholder<GrabbableTraveler>(
                    onDragAccepted: (source) {
                      switch (source) {
                        case EntityTraveler traveler:
                          storage.moveEntity(traveler.passport, position);
                          editSubject.value = EntitySubject(position);
                        case CreationTraveler _:
                          storage.createEntity(
                            position,
                            AppLocalizations.of(context)!.newEntity,
                          );
                          editSubject.value = EntitySubject(position);
                      }
                    },
                    boundaries: boundaries,
                    position: position,
                  ),
              };
            }.listen(listenableEntity);

            cells.add(cell.expand().keyed(ValueKey(x)));
          }

          rows.add(cells.row.expand().keyed(ValueKey(y)));
        }

        return rows.column;
      }.listen(storage.listenableBoundaries).group,
    );
  }
}
