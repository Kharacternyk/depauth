import 'package:flutter/material.dart';

class PendingValueNotifier<T> extends ValueNotifier<T> {
  final T initialValue;

  PendingValueNotifier(this.initialValue) : super(initialValue);

  bool get dirty => value != initialValue;
}
