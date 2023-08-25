import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';
import 'package:path/path.dart';

import 'core/insightful_storage.dart';
import 'core/position.dart';
import 'core/traveler.dart';
import 'core/traversable_entity.dart';
import 'entity_form.dart';
import 'entity_graph.dart';
import 'menu_drawer.dart';
import 'scaled_draggable.dart';
import 'split_view.dart';
import 'storage_form.dart';
import 'viewer.dart';

class ControlPanel extends StatefulWidget {
  final String storageName;
  final Iterable<String> storageNames;
  final String workingDirectory;

  const ControlPanel({
    required this.storageName,
    required this.storageNames,
    required this.workingDirectory,
    super.key,
  });

  @override
  createState() => _State(storageName, storageNames.toSet());
}

class _State extends State<ControlPanel> {
  final editablePosition = ValueNotifier<Position?>(null);
  final formHasTraveler = ValueNotifier<bool>(false);
  final Set<String> storageNames;
  String storageName;
  InsightfulStorage? storage;

  _State(this.storageName, this.storageNames);

  @override
  deactivate() {
    storage?.dispose();
    super.deactivate();
  }

  @override
  activate() {
    super.activate();
    _initStorage();
  }

  @override
  initState() {
    super.initState();
    _initStorage();
    storageNames.add(storageName);
  }

  void _initStorage() {
    storage = InsightfulStorage(
      join(widget.workingDirectory, '$storageName.depauth'),
      entityDuplicatePrefix: ' (',
      entityDuplicateSuffix: ')',
    );
  }

  @override
  build(BuildContext context) {
    final InsightfulStorage storage;
    switch (this.storage) {
      case null:
        return const Center(child: CircularProgressIndicator());
      case InsightfulStorage reusableStorage:
        storage = reusableStorage;
    }

    final messages = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final storageForm = ValueListenableBuilder(
      valueListenable: storage.storageInsight,
      builder: (context, value, child) {
        return StorageForm(
          insight: value,
          resetLoss: storage.resetLoss,
          resetCompromise: storage.resetCompromise,
        );
      },
    );

    return Scaffold(
      drawer: const MenuDrawer(),
      body: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: formHasTraveler,
            builder: (context, value, child) {
              return Ink(
                color: value ? colors.primaryContainer : colors.surfaceVariant,
              );
            },
          ),
          SplitView(
            mainChild: Material(
              child: Viewer(
                minScale: 1,
                maxScale: 20,
                child: EntityGraph(
                  storage,
                  setEditablePosition: (position) {
                    editablePosition.value = position;
                  },
                ),
              ),
            ),
            sideChild: ValueListenableBuilder(
              valueListenable: editablePosition,
              builder: (context, sideBar, child) {
                switch (editablePosition.value) {
                  case null:
                    return storageForm;
                  case Position position:
                    final listenableEntity =
                        storage.getListenableEntity(position);

                    return ValueListenableBuilder(
                      valueListenable: listenableEntity,
                      builder: (context, entity, child) {
                        return switch (entity) {
                          TraversableEntity entity => ListenableBuilder(
                              listenable: storage.entityInsightNotifier,
                              builder: (child, context) => EntityForm(
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
                              ),
                            ),
                          null => storageForm,
                        };
                      },
                    );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            const DrawerButton(),
            const Spacer(),
            DragTarget<DeletableTraveler>(
              builder: (context, candidate, rejected) {
                return FloatingActionButton(
                  backgroundColor: candidate.isNotEmpty
                      ? colors.error
                      : colors.errorContainer,
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
                    storage.deleteEntity(traveler.position);
                  case FactorTraveler traveler:
                    storage.removeFactor(traveler.position, traveler.factor);
                  case DependencyTraveler traveler:
                    storage.removeDependency(
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
          ],
        ),
      ),
    );
  }
}
