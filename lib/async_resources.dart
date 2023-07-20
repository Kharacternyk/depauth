import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class AsyncResources extends InheritedWidget {
  final String documentsDirectory;

  const AsyncResources._(
    this.documentsDirectory, {
    required super.child,
  });

  static AsyncResources of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AsyncResources>()!;

  static Future<AsyncResources> get(Widget child) async {
    final values = await Future.wait(
      [
        _getDocumentsDirectory(),
      ],
      eagerError: true,
    );
    return AsyncResources._(values[0], child: child);
  }

  static Future<String> _getDocumentsDirectory() async {
    String globalDirectory;

    try {
      globalDirectory = (await getApplicationDocumentsDirectory()).path;
    } on MissingPlatformDirectoryException {
      globalDirectory = '.';
    }

    final localDirectory = join(globalDirectory, 'DepAuth');
    await Directory(localDirectory).create();

    return localDirectory;
  }

  @override
  bool updateShouldNotify(oldWidget) => false;
}
