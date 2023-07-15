import 'package:flutter/material.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'viewer.dart';

class ScaledLine extends StatelessWidget {
  final Widget child;
  final Color color;
  final String targetId;
  final String id;

  const ScaledLine({
    required this.child,
    required this.color,
    required this.targetId,
    required this.id,
    super.key,
  });

  @override
  build(context) {
    return ArrowElement(
      id: id,
      color: color,
      sourceAnchor: Alignment.topCenter,
      targetAnchor: Alignment.bottomCenter,
      tipLength: 0,
      width: 4 *
          switch (Scale.maybeOf(context)) {
            null => 1,
            Scale scale => 1 / scale.value,
          },
      targetId: targetId,
      child: child,
    );
  }
}
