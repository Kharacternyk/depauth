import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:path/path.dart';

import 'core/entity.dart';
import 'core/factor.dart';
import 'core/insightful_storage.dart';
import 'core/position.dart';
import 'core/storage.dart';
import 'core/traveler.dart';
import 'core/traversable_entity.dart';
import 'entity_form.dart';
import 'entity_graph.dart';
import 'scaled_draggable.dart';
import 'split_view.dart';
import 'viewer.dart';
import 'widget_extension.dart';

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

    const addButtonTooltip =
        "Drag this button onto an empty space to create a new entity.";
    const deleteButtonTooltip = "Drag onto this button to delete.";
    final colors = Theme.of(context).colorScheme;
    final defaultSideBar = const Text('Press on a card to edit it.').fit();

    return Scaffold(
      body: SplitView(
        mainChild: Viewer(
          minScale: 1,
          maxScale: 20,
          child: EntityGraph(
            storage,
            setEditablePosition: (position) {
              editablePosition.value = position;
            },
          ),
        ),
        sideChild: Material(
          color: colors.surfaceVariant,
          child: ValueListenableBuilder(
            valueListenable: editablePosition,
            builder: (context, sideBar, child) {
              switch (editablePosition.value) {
                case null:
                  return defaultSideBar;
                case Position position:
                  final listenableEntity =
                      storage.getListenableEntity(position);

                  return ValueListenableBuilder(
                    valueListenable: listenableEntity,
                    builder: (context, entity, child) {
                      return switch (entity) {
                        TraversableEntity entity => ListenableBuilder(
                            listenable: storage.insightNotifier,
                            builder: (child, context) => EntityForm(
                              entity,
                              position: position,
                              goBack: () {
                                editablePosition.value = null;
                              },
                              insight: storage.getInsight(entity.identity),
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
              }
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            PopupMenuButton(
              itemBuilder: (_) {
                return [
                  ...storageNames.map((name) {
                    return PopupMenuItem(
                      value: name,
                      child: AbsorbPointer(
                        child: ListTile(
                          leading: const Icon(Icons.file_open),
                          title: Text(name),
                          subtitle: const Text('Open file'),
                        ),
                      ),
                    );
                  }),
                  const PopupMenuItem(
                    value: null,
                    child: AbsorbPointer(
                      child: ListTile(
                        leading: Icon(Icons.add),
                        title: Text('Create new file'),
                      ),
                    ),
                  ),
                ];
              },
              onSelected: (name) {
                setState(() {
                  switch (name) {
                    case String name:
                      storageName = name;
                      storage.dispose();
                      _initStorage();
                    case null:
                  }
                });
              },
              icon: [
                const Icon(Icons.more_vert),
                ScalableImageWidget.fromSISource(
                  si: ScalableImageSource.fromSI(
                    DefaultAssetBundle.of(context),
                    'assets/logo.si',
                  ),
                ).fit(),
                const SizedBox(width: 4),
              ].toRow(),
            ),
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
                        const SnackBar(
                          content: Text(deleteButtonTooltip),
                          showCloseIcon: true,
                        ),
                      );
                  },
                  tooltip: deleteButtonTooltip,
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
                      const SnackBar(
                        content: Text(addButtonTooltip),
                        showCloseIcon: true,
                      ),
                    );
                },
                tooltip: addButtonTooltip,
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
