import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';

import 'core/entity.dart';
import 'core/fraction.dart';
import 'entity_graph.dart';
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Map<(int, int), Entity> entities = {
    (1, 1): Entity(
      type: EntityType.webService,
      name: 'Google',
      dependsOn: {
        'Yubikey': Fraction(1, 2),
        'Nazar': Fraction(1, 2),
        'Fastmail': Fraction(1, 2),
      },
    ),
    (1, 2): Entity(
      type: EntityType.webService,
      name: 'Fastmail',
      dependsOn: {
        'Yubikey': Fraction(1, 2),
        'Nazar': Fraction(1, 2),
        'Google': Fraction(1, 2),
      },
    ),
    (2, 2): Entity(
      type: EntityType.webService,
      name: 'GitHub',
      dependsOn: {
        'Google': Fraction(1, 2),
        'Yubikey': Fraction(1, 2),
        'Nazar': Fraction(1, 2)
      },
    ),
    (0, 2): Entity(
      type: EntityType.webService,
      name: 'LinkedIn',
      dependsOn: {'Google': Fraction(1, 1), 'Nazar': Fraction(1, 1)},
    ),
    (2, 0): const Entity(
      type: EntityType.hardwareKey,
      name: 'Yubikey',
    ),
    (0, 0): const Entity(
      type: EntityType.person,
      name: 'Nazar',
    ),
    (0, 1): const Entity(
      type: EntityType.person,
      name: 'Romesh Ranghanathan',
    ),
  };

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
      body: Viewer(
        minScale: 1,
        maxScale: 20,
        builder: (scale) => EntityGraph(
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
