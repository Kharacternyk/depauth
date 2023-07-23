import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';
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
  Widget? drawer;

  @override
  build(BuildContext context) {
    const addEntityTooltip =
        "Drag this button onto an empty space to create a new entity.";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        title: ScalableImageWidget.fromSISource(
          si: ScalableImageSource.fromSI(
            DefaultAssetBundle.of(context),
            'assets/logo.si',
          ),
          scale: 0.1,
        ),
      ),
      body: Row(
        children: [
          Expanded(
            child: Viewer(
              minScale: 1,
              maxScale: 20,
              child: EntityGraph(
                setDrawer: (widget) {
                  setState(() {
                    drawer = widget;
                  });
                },
                join(
                  AsyncResources.of(context).documentsDirectory,
                  'personal.depauth',
                ),
              ),
            ),
          ),
          drawer ?? const SizedBox.shrink(),
        ],
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
