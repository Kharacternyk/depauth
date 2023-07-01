import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';

import 'core/entity.dart';
import 'entity_graph.dart';

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
    (0, 3): const Entity(
      type: EntityType.webService,
      name: 'GitHub',
    ),
    (1, 2): const Entity(
      type: EntityType.webService,
      name: 'AWS',
    ),
    (2, 3): const Entity(
      type: EntityType.hardwareKey,
      name: 'Yubikey 5 NFC',
    ),
    (3, 3): const Entity(
      type: EntityType.hardwareKey,
      name: 'Yubikey 4',
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
        minScale: 1,
        maxScale: 20,
        transformationController: transformationController,
        onInteractionEnd: (_) => setState(() {
          scale = transformationController.value.getMaxScaleOnAxis();
        }),
        child: EntityGraph(
          entities,
          scale: scale,
          move: (destination, source) {
            setState(() {
              final point = entities.remove(source);
              if (point != null) {
                entities[destination] = point;
              }
            });
          },
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
