import 'package:flutter/material.dart';

class LateWidget extends StatelessWidget {
  final Widget Function() builder;

  LateWidget(this.builder, {super.key});

  late final Widget _child = builder();

  @override
  build(context) => _child;
}
