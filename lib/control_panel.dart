import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'application_storage.dart';
import 'core/position.dart';
import 'core/storage_insight.dart';
import 'core/traveler.dart';
import 'core/traversable_entity.dart';
import 'entity_form.dart';
import 'entity_graph.dart';
import 'menu_drawer.dart';
import 'scaled_draggable.dart';
import 'split_view.dart';
import 'storage_form.dart';
import 'viewer.dart';
import 'widget_extension.dart';

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  createState() => _State();
}

class _State extends State<ControlPanel> {
  final editablePosition = ValueNotifier<Position?>(null);
  final formHasTraveler = ValueNotifier(false);
  final storage = ValueNotifier<ApplicationStorage?>(null);

  @override
  initState() {
    super.initState();
    ApplicationStorage.listStorageNames().then((names) {
      final name = names.firstOrNull ?? 'Personal';
      return ApplicationStorage.getStorage(name);
    }).then((value) {
      storage.value = value;
    });
  }

  @override
  deactivate() {
    storage.value?.dispose();
    super.deactivate();
  }

  @override
  activate() {
    super.activate();
    if (storage.value case ApplicationStorage deactivatedStorage) {
      storage.value = ApplicationStorage(deactivatedStorage.path);
    }
  }

  @override
  dispose() {
    storage.value?.dispose();
    storage.dispose();
    editablePosition.dispose();
    formHasTraveler.dispose();
    super.dispose();
  }

  @override
  build(BuildContext context) {
    const spinner = Center(child: CircularProgressIndicator());
    final messages = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final storageForm = (ApplicationStorage? storage) {
      if (storage case ApplicationStorage storage) {
        return (StorageInsight insight) {
          return StorageForm(
            insight: insight,
            resetLoss: storage.resetLoss,
            resetCompromise: storage.resetCompromise,
          );
        }.listen(storage.storageInsight);
      }
      return spinner;
    }.listen(storage);

    return Scaffold(
      drawer: const MenuDrawer(),
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
                child: (ApplicationStorage? storage) {
                  if (storage case ApplicationStorage storage) {
                    return EntityGraph(
                      storage,
                      setEditablePosition: (position) {
                        editablePosition.value = position;
                      },
                    );
                  }
                  return spinner;
                }.listen(storage),
              ),
            ),
            sideChild: (ApplicationStorage? storage) {
              if (storage case ApplicationStorage storage) {
                return (Position? position) {
                  switch (position) {
                    case null:
                      return storageForm;
                    case Position position:
                      final listenableEntity =
                          storage.getListenableEntity(position);

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
                                insight:
                                    storage.getEntityInsight(entity.identity),
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
                                addDependency: (factor, entity) {
                                  storage.addDependency(
                                    position,
                                    factor,
                                    entity,
                                  );
                                },
                                addDependencyAsFactor: (dependency) {
                                  storage.addDependencyAsFactor(
                                    position,
                                    entity: entity.identity,
                                    dependency: dependency,
                                  );
                                },
                                removeDependency: (factor, entity) {
                                  storage.removeDependency(
                                    position,
                                    factor,
                                    entity,
                                  );
                                },
                                addFactor: () {
                                  storage.addFactor(position, entity.identity);
                                },
                              );
                            }.listen(storage.entityInsightNotifier),
                          null => storageForm,
                        };
                      }.listen(listenableEntity);
                  }
                }.listen(editablePosition);
              }
              return spinner;
            }.listen(storage),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: [
          const DrawerButton(),
          (ApplicationStorage? storage) {
            if (storage case ApplicationStorage storage) {
              return Text(
                storage.path,
                overflow: TextOverflow.fade,
                softWrap: false,
              ).tip(storage.path);
            }
            return spinner;
          }.listen(storage).expand(),
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
                  storage.value?.deleteEntity(traveler.position);
                case FactorTraveler traveler:
                  storage.value
                      ?.removeFactor(traveler.position, traveler.factor);
                case DependencyTraveler traveler:
                  storage.value?.removeDependency(
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
