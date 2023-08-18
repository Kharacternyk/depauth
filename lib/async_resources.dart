import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class AsyncResources extends InheritedWidget {
  final String documentsDirectory;
  final Iterable<String> documentNames;

  const AsyncResources._(
    this.documentsDirectory,
    this.documentNames, {
    required super.child,
  });

  static AsyncResources of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AsyncResources>()!;

  static Future<AsyncResources> get(Widget child) async {
    final values = await Future.wait(
      [
        _getDocuments(),
      ],
      eagerError: true,
    );

    return AsyncResources._(values[0].directory, values[0].names, child: child);
  }

  static Future<({String directory, Iterable<String> names})>
      _getDocuments() async {
    String globalDirectory;

    try {
      globalDirectory = (await getApplicationDocumentsDirectory()).path;
    } on MissingPlatformDirectoryException {
      globalDirectory = '.';
    }

    final localDirectory = join(globalDirectory, 'DepAuth');
    await Directory(localDirectory).create();

    final documentNames = await Directory(localDirectory).list().toList();

    return (
      directory: localDirectory,
      names: documentNames.map((file) => basenameWithoutExtension(file.path))
    );
  }

  @override
  bool updateShouldNotify(oldWidget) => false;
}
