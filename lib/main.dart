import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';

import 'core/entity_source.dart';
import 'entity_graph.dart';
import 'scaled_draggable.dart';
import 'viewer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  build(BuildContext context) {
    return MaterialApp(
      title: 'DepAuth',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'DepAuth'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  build(BuildContext context) {
    const addEntityTooltip =
        "Drag this button onto an empty space to create a new entity.";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            ScalableImageWidget.fromSISource(
              si: ScalableImageSource.fromSI(
                DefaultAssetBundle.of(context),
                'assets/logo.si',
              ),
              scale: 0.1,
            ),
            Text(title),
          ],
        ),
      ),
      body: Viewer(
        minScale: 1,
        maxScale: 20,
        builder: (scale) => EntityGraph(
          scale: scale,
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
