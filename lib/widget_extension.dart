import 'package:flutter/material.dart';

extension WidgetExtension on Widget {
  FittedBox fit({Key? key}) => FittedBox(key: key, child: this);
  Expanded expand({Key? key, int flex = 1}) =>
      Expanded(key: key, flex: flex, child: this);
  Padding pad(EdgeInsets padding, {Key? key}) =>
      Padding(key: key, padding: padding, child: this);
  SizedBox grow({Key? key}) => SizedBox.expand(key: key, child: this);
  Card toCard({Key? key}) => Card(key: key, child: this);
  Opacity hideIf(bool condition, {Key? key}) =>
      Opacity(opacity: condition ? 0 : 1, key: key, child: this);
  Tooltip tip(String message, {Key? key}) =>
      Tooltip(message: message, key: key, child: this);
  FocusTraversalGroup group({Key? key}) =>
      FocusTraversalGroup(key: key, child: this);
}

extension WidgetListExtension on List<Widget> {
  Column toColumn({Key? key}) => Column(key: key, children: this);
  Row toRow({Key? key}) => Row(key: key, children: this);
}

extension ValueBuilderExtension<T> on Widget Function(T) {
  ValueListenableBuilder<T> listen(ValueNotifier<T> notifier, {Key? key}) =>
      ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, value, child) => this.call(value),
      );
}

extension BuilderExtension on Widget Function() {
  ListenableBuilder listen(Listenable notifier, {Key? key}) =>
      ListenableBuilder(
        listenable: notifier,
        builder: (context, child) => this.call(),
      );
}
