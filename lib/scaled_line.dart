import 'package:flutter/material.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'scale.dart';

class ScaledLine extends StatelessWidget {
  final Widget child;
  final Color color;
  final String targetName;
  final String name;

  const ScaledLine({
    required this.child,
    required this.color,
    required this.targetName,
    required this.name,
    super.key,
  });

  @override
  build(context) {
    return ArrowElement(
      id: name,
      color: color,
      sourceAnchor: Alignment.topCenter,
      targetAnchor: Alignment.bottomCenter,
      tipLength: 0,
      width: 3 /
          switch (Scale.maybeOf(context)) {
            null => 1,
            Scale scale => scale.value,
          },
      targetId: targetName,
      child: child,
    );
  }
}
