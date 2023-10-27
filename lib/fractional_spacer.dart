import 'package:flutter/material.dart';

class FractionalSpacer extends StatelessWidget {
  final double flex;
  final int factor;
  final Widget? child;

  const FractionalSpacer(
    this.flex, {
    this.factor = 1000,
    this.child,
    super.key,
  });

  @override
  build(context) {
    final child = this.child;
    final flex = (this.flex * factor).round();

    if (flex <= 0) {
      return const SizedBox.shrink();
    }

    return child != null
        ? Expanded(flex: flex, child: child)
        : Spacer(flex: flex);
  }
}
