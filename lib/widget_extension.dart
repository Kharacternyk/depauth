import 'package:flutter/material.dart';

extension WidgetExtension on Widget {
  Widget fit({Key? key}) => FittedBox(key: key, child: this);
  Widget expand({Key? key, int flex = 1}) =>
      Expanded(key: key, flex: flex, child: this);
  Widget pad(EdgeInsets padding, {Key? key}) =>
      Padding(key: key, padding: padding, child: this);
  Widget grow({Key? key}) => SizedBox.expand(key: key, child: this);
}

extension WidgetListExtension on List<Widget> {
  Widget toColumn({Key? key}) => Column(key: key, children: this);
  Widget toRow({Key? key}) => Row(key: key, children: this);
}
