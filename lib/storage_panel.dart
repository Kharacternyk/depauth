import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'application_storage.dart';
import 'core/position.dart';
import 'core/storage_insight.dart';
import 'core/traveler.dart';
import 'core/traversable_entity.dart';
import 'entity_form.dart';
import 'entity_graph.dart';
import 'scaled_draggable.dart';
import 'split_view.dart';
import 'storage_form.dart';
import 'viewer.dart';
import 'widget_extension.dart';

class StoragePanel extends StatefulWidget {
  final ApplicationStorage storage;
  final Widget drawer;

  const StoragePanel({
    required this.storage,
    required this.drawer,
    super.key,
  });

  @override
  createState() => _State();
}

class _State extends State<StoragePanel> {
  final editablePosition = ValueNotifier<Position?>(null);
  final formHasTraveler = ValueNotifier(false);

  @override
  dispose() {
    editablePosition.dispose();
    formHasTraveler.dispose();
    super.dispose();
  }

  @override
  build(BuildContext context) {
    final messages = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final storageForm = (StorageInsight insight) {
      return StorageForm(
        insight: insight,
        resetLoss: widget.storage.resetLoss,
        resetCompromise: widget.storage.resetCompromise,
      );
    }.listen(widget.storage.storageInsight);

    return Scaffold(
      drawer: widget.drawer,
      body: Stack(
        children: [
          (bool formHasTraveler) {
            return Ink(
              color: formHasTraveler
                  ? colors.primaryContainer
                  : colors.surfaceVariant,
            );
          }.listen(formHasTraveler),
          SplitView(
            mainChild: Material(
              child: Viewer(
                minScale: 1,
                maxScale: 20,
                child: EntityGraph(
                  widget.storage,
                  setEditablePosition: (position) {
                    editablePosition.value = position;
                  },
                ),
              ),
            ),
            sideChild: (Position? position) {
              switch (position) {
                case null:
                  return storageForm;
                case Position position:
                  final listenableEntity =
                      widget.storage.getListenableEntity(position);

                  return (TraversableEntity? entity) {
                    return switch (entity) {
                      TraversableEntity entity => () {
                          return EntityForm(
                            entity,
                            position: position,
                            hasTraveler: formHasTraveler,
                            goBack: () {
                              editablePosition.value = null;
                            },
                            insight: widget.storage
                                .getEntityInsight(entity.identity),
                            changeName: (name) {
                              widget.storage.changeName(position, name);
                            },
                            changeType: (type) {
                              widget.storage.changeType(position, type);
                            },
                            toggleLost: (value) {
                              widget.storage.toggleLost(position, value);
                            },
                            toggleCompromised: (value) {
                              widget.storage.toggleCompromised(position, value);
                            },
                            addDependency: (factor, entity) {
                              widget.storage.addDependency(
                                position,
                                factor,
                                entity,
                              );
                            },
                            addDependencyAsFactor: (dependency) {
                              widget.storage.addDependencyAsFactor(
                                position,
                                entity: entity.identity,
                                dependency: dependency,
                              );
                            },
                            removeDependency: (factor, entity) {
                              widget.storage.removeDependency(
                                position,
                                factor,
                                entity,
                              );
                            },
                            addFactor: () {
                              widget.storage
                                  .addFactor(position, entity.identity);
                            },
                          );
                        }.listen(widget.storage.entityInsightNotifier),
                      null => storageForm,
                    };
                  }.listen(listenableEntity);
              }
            }.listen(editablePosition),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: [
          const DrawerButton(),
          (String name) {
            return Text(
              name,
              overflow: TextOverflow.fade,
              softWrap: false,
            ).tip(name);
          }.listen(widget.storage.name).expand(),
          DragTarget<DeletableTraveler>(
            builder: (context, candidate, rejected) {
              return FloatingActionButton(
                backgroundColor:
                    candidate.isNotEmpty ? colors.error : colors.errorContainer,
                foregroundColor: candidate.isNotEmpty
                    ? colors.onError
                    : colors.onErrorContainer,
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(messages.deleteButtonTooltip),
                        showCloseIcon: true,
                      ),
                    );
                },
                tooltip: messages.deleteButtonTooltip,
                child: const Icon(Icons.delete),
              );
            },
            onAccept: (traveler) {
              switch (traveler) {
                case EntityTraveler traveler:
                  widget.storage.deleteEntity(traveler.position);
                case FactorTraveler traveler:
                  widget.storage
                      .removeFactor(traveler.position, traveler.factor);
                case DependencyTraveler traveler:
                  widget.storage.removeDependency(
                    traveler.position,
                    traveler.factor,
                    traveler.entity,
                  );
              }
            },
          ),
          const SizedBox(width: 8),
          ScaledDraggable(
            dragData: const CreationTraveler(),
            child: FloatingActionButton(
              onPressed: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(messages.addButtonTooltip),
                      showCloseIcon: true,
                    ),
                  );
              },
              tooltip: messages.addButtonTooltip,
              mouseCursor: SystemMouseCursors.grab,
              child: const Icon(Icons.add),
            ),
          ),
        ].row.group,
      ),
    );
  }
}
