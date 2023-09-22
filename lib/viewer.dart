import 'package:flutter/material.dart';

class Viewer extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;

  const Viewer({
    required this.child,
    required this.minScale,
    required this.maxScale,
    super.key,
  });

  @override
  createState() => _State();
}

class Scale extends InheritedWidget {
  final double value;

  const Scale(this.value, {required super.child, super.key});

  @override
  updateShouldNotify(Scale oldWidget) => value != oldWidget.value;

  static Scale? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Scale>();
}

class _State extends State<Viewer> {
  final transformationController = TransformationController();
  late var scale = transformationController.value.getMaxScaleOnAxis();

  @override
  dispose() {
    transformationController.dispose();
    super.dispose();
  }

  @override
  build(context) {
    return InteractiveViewer(
      minScale: widget.minScale,
      maxScale: widget.maxScale,
      transformationController: transformationController,
      onInteractionEnd: (details) {
        setState(() {
          scale = transformationController.value.getMaxScaleOnAxis();
        });
      },
      child: Scale(scale, child: widget.child),
    );
  }
}
