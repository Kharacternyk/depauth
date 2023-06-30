import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';

import 'entity.dart';
import 'entity_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  TransformationController transformationController =
      TransformationController();
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
        transformationController: transformationController,
        onInteractionEnd: (_) => setState(() {
          scale = transformationController.value.getMaxScaleOnAxis();
        }),
        child: Stack(
          children: [
            EntityWidget(
              Entity(
                x: 50,
                y: 100,
                scale: scale,
                type: EntityType.webService,
                name: 'Google',
              ),
            ),
            EntityWidget(
              Entity(
                x: 200,
                y: 200,
                scale: scale,
                type: EntityType.hardwareKey,
                name: 'Yubikey',
              ),
            ),
          ],
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
