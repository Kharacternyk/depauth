import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:path/path.dart';

import 'async_resources.dart';
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
import 'viewer.dart';
import 'widget_extension.dart';

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  createState() => _State();
}

class _State extends State<ControlPanel> {
  final editablePosition = ValueNotifier<Position?>(null);
  InsightfulStorage? storage;

  @override
  dispose() {
    storage?.dispose();
    super.dispose();
  }

  @override
  build(BuildContext context) {
    final InsightfulStorage storage;
    switch (this.storage) {
      case null:
        storage = InsightfulStorage(
          join(
            AsyncResources.of(context).documentsDirectory,
            'personal.depauth',
          ),
          entityDuplicatePrefix: ' (',
          entityDuplicateSuffix: ')',
        );
      case InsightfulStorage reusableStorage:
        storage = reusableStorage;
    }

    const addButtonTooltip =
        "Drag this button onto an empty space to create a new entity.";
    const deleteButtonTooltip = "Drag onto this button to delete.";
    final colors = Theme.of(context).colorScheme;
    final defaultSideBar = const Text('Press on a card to edit it.').fit();

    return Scaffold(
      body: MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
          dividerPainter: DividerPainters.grooved1(
            backgroundColor: colors.surfaceVariant,
            color: colors.onSurfaceVariant,
            highlightedColor: colors.primary,
          ),
        ),
        child: MultiSplitView(
          axis: switch (MediaQuery.of(context).orientation) {
            Orientation.portrait => Axis.vertical,
            Orientation.landscape => Axis.horizontal,
          },
          initialAreas: [
            Area(weight: 0.7),
          ],
          children: [
            Viewer(
              minScale: 1,
              maxScale: 20,
              child: EntityGraph(
                storage,
                setEditablePosition: (position) {
                  editablePosition.value = position;
                },
              ),
            ),
            Material(
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
                                    storage.addFactor(
                                        position, entity.identity);
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
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton.filledTonal(
              onPressed: () {},
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
