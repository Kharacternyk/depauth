import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:multi_split_view/multi_split_view.dart';
import 'package:path/path.dart';

import 'async_resources.dart';
import 'core/entity_source.dart';
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

  @override
  build(BuildContext context) {
    const addEntityTooltip =
        "Drag this button onto an empty space to create a new entity.";
    final colors = Theme.of(context).colorScheme;
    final defaultSideBar = Column(
      children: [
        FittedBox(
          child: ScalableImageWidget.fromSISource(
            si: ScalableImageSource.fromSI(
              DefaultAssetBundle.of(context),
              'assets/logo.si',
            ),
          ),
        ),
        const Text('Press on a card to edit it.'),
      ],
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
                defaultSideBar: defaultSideBar,
                setSideBar: (widget) {
                  sideBar.value = widget;
                },
                join(
                  AsyncResources.of(context).documentsDirectory,
                  'personal.depauth',
                ),
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
      floatingActionButton: ScaledDraggable(
        dragData: const NewEntitySource(),
        child: FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(addEntityTooltip),
                showCloseIcon: true,
              ),
            );
          },
          tooltip: addEntityTooltip,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
