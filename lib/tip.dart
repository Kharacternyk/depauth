import 'package:flutter/material.dart';

class Tip extends StatelessWidget {
  final String message;

  const Tip(this.message, {super.key});

  @override
  build(context) {
    final style = Theme.of(context).textTheme.bodySmall;

    return Text(message, style: style);
  }
}
