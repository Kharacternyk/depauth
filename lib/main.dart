import 'package:flutter/material.dart';

import 'async_resources.dart';
import 'control_panel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final asyncResources = await AsyncResources.get(const MyApp());
  runApp(asyncResources);
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
      home: const ControlPanel(),
    );
  }
}
