import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';

import 'core/entity.dart';
import 'entity_chip.dart';
import 'entity_placeholder.dart';

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
          seedColor: Colors.cyan,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'DepAuth'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TransformationController transformationController =
      TransformationController();
  final Map<(int, int), Entity> entities = {
    (0, 1): const Entity(
      type: EntityType.webService,
      name: 'Google',
    ),
    (2, 3): const Entity(
      type: EntityType.hardwareKey,
      name: 'Yubikey',
    ),
    (1, 4): const Entity(
      type: EntityType.person,
      name: 'Nazar',
    ),
  };
  double scale = 0;

  @override
  initState() {
    super.initState();
    scale = transformationController.value.getMaxScaleOnAxis();
  }

  @override
  build(BuildContext context) {
    final rows = <Expanded>[];
    for (var i = 0; i < 5; ++i) {
      final row = <Widget>[];
      for (var j = 0; j < 5; ++j) {
        if (entities.containsKey((i, j))) {
          row.add(
            EntityChip<(int, int)>(
              entities[(i, j)]!,
              scale: scale,
              dragData: (i, j),
            ),
          );
        } else {
          row.add(EntityPlaceholder<(int, int)>(
            onDragAccepted: (point) {
              setState(() {
                entities[(i, j)] = entities.remove(point)!;
              });
            },
          ));
        }
      }
      rows.add(Expanded(child: Row(children: row)));
    }

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
            Text(widget.title),
          ],
        ),
      ),
      body: InteractiveViewer(
        transformationController: transformationController,
        onInteractionEnd: (_) => setState(() {
          scale = transformationController.value.getMaxScaleOnAxis();
        }),
        child: Column(
          children: rows,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
