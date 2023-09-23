import 'package:flutter/material.dart';

class Scale extends InheritedWidget {
  final double value;

  const Scale(this.value, {required super.child, super.key});

  @override
  updateShouldNotify(Scale oldWidget) => value != oldWidget.value;

  static Scale? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Scale>();
}
