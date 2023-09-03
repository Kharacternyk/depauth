import 'package:flutter/material.dart';

extension WidgetExtension on Widget {
  FittedBox get fit => FittedBox(child: this);
  Expanded expand([int flex = 1]) => Expanded(flex: flex, child: this);
  Padding pad(EdgeInsets padding) => Padding(padding: padding, child: this);
  SizedBox get grow => SizedBox.expand(child: this);
  Card get card => Card(child: this);
  Opacity hideIf(bool condition) =>
      Opacity(opacity: condition ? 0 : 1, child: this);
  Tooltip tip(String message) => Tooltip(message: message, child: this);
  FocusTraversalGroup get group => FocusTraversalGroup(child: this);
  KeyedSubtree keyed(Key key) => KeyedSubtree(key: key, child: this);
}

extension WidgetListExtension on List<Widget> {
  Column get column => Column(children: this);
  Row get row => Row(children: this);
}

extension ValueBuilderExtension<T> on Widget Function(T) {
  ValueListenableBuilder<T> listen(ValueNotifier<T> notifier) =>
      ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, value, child) => call(value),
      );
}

extension BuilderExtension on Widget Function() {
  ListenableBuilder listen(Listenable notifier) => ListenableBuilder(
        listenable: notifier,
        builder: (context, child) => call(),
      );
}
