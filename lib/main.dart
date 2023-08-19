import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'control_panel.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  createState() => _State();
}

class _State extends State<App> {
  final workingDirectory = ValueNotifier<String?>(null);
  Iterable<String> storageNames = const [];

  @override
  initState() {
    super.initState();
    _initState();
  }

  void _initState() async {
    String globalDirectory;

    try {
      globalDirectory = (await getApplicationDocumentsDirectory()).path;
    } on MissingPlatformDirectoryException {
      globalDirectory = '.';
    }

    final localDirectory = join(globalDirectory, 'DepAuth');
    await Directory(localDirectory).create();

    storageNames = await Directory(localDirectory)
        .list()
        .where((file) => extension(file.path) == '.depauth')
        .map((file) => basenameWithoutExtension(file.path))
        .toList();

    workingDirectory.value = localDirectory;
  }

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
      home: ValueListenableBuilder(
        valueListenable: workingDirectory,
        builder: (context, workingDirectory, child) {
          return switch (workingDirectory) {
            String workingDirectory => ControlPanel(
                workingDirectory: workingDirectory,
                storageNames: storageNames,
                storageName: 'Personal',
              ),
            null => const Center(child: CircularProgressIndicator()),
          };
        },
      ),
    );
  }
}
