import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:path/path.dart';

import 'async_resources.dart';
import 'core/db.dart';
import 'core/traveler.dart';
import 'entity_graph.dart';
import 'scaled_draggable.dart';
import 'viewer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  createState() => _State();
}

class _State extends State<HomePage> {
  final sideBar = ValueNotifier<Widget?>(null);
  Db? db;

  @override
  dispose() {
    db?.dispose();
    super.dispose();
  }

  @override
  build(BuildContext context) {
    final Db db;
    switch (this.db) {
      case null:
        db = Db(
          join(
            AsyncResources.of(context).documentsDirectory,
            'personal.depauth',
          ),
          entityDuplicatePrefix: ' (',
          entityDuplicateSuffix: ')',
        );
      case Db db_:
        db = db_;
    }

    const addButtonTooltip =
        "Drag this button onto an empty space to create a new entity.";
    const deleteButtonTooltip = "Drag onto this button to delete.";
    final colors = Theme.of(context).colorScheme;
    final defaultSideBar = FittedBox(
      child: Column(
        children: [
          ScalableImageWidget.fromSISource(
            si: ScalableImageSource.fromSI(
              DefaultAssetBundle.of(context),
              'assets/logo.si',
            ),
            scale: 0.2,
          ),
          const Text('Press on a card to edit it.'),
        ],
      ),
    );

    return Scaffold(
      body: MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
          dividerPainter: DividerPainters.grooved1(
            backgroundColor: colors.secondaryContainer,
            color: colors.onSecondaryContainer,
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
                db,
                defaultSideBar: defaultSideBar,
                setSideBar: (widget) {
                  sideBar.value = widget;
                },
              ),
            ),
            Material(
              color: colors.secondaryContainer,
              child: ValueListenableBuilder(
                valueListenable: sideBar,
                builder: (context, sideBar, child) {
                  return sideBar ?? defaultSideBar;
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
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
                    db.deleteEntity(traveler.position);
                  case FactorTraveler traveler:
                    db.removeFactor(traveler.position, traveler.id);
                  case DependencyTraveler traveler:
                    db.removeDependency(
                      traveler.position,
                      traveler.factorId,
                      traveler.entityId,
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
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
