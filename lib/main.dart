import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'control_panel.dart';
import 'widget_extension.dart';

void main() {
  runApp(const Application());
}

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  createState() => _State();
}

class _State extends State<Application> {
  final workingDirectory = ValueNotifier<String?>(null);
  Iterable<String> storageNames = const [];

  @override
  initState() {
    super.initState();
    _initState();
  }

  @override
  dispose() {
    workingDirectory.dispose();
    super.dispose();
  }

  @override
  build(BuildContext context) {
    return MaterialApp(
      title: 'DepAuth',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: SafeArea(
        child: (String? workingDirectory) {
          return switch (workingDirectory) {
            String workingDirectory => ControlPanel(
                workingDirectory: workingDirectory,
                storageNames: storageNames,
                storageName: 'Personal',
              ),
            null => const Center(child: CircularProgressIndicator()),
          };
        }.listen(workingDirectory),
      ),
    );
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
}
