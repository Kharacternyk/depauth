import 'package:flutter/material.dart';

class Viewer extends StatefulWidget {
  final Widget Function(double scale) builder;
  final double minScale;
  final double maxScale;

  const Viewer({
    required this.builder,
    required this.minScale,
    required this.maxScale,
    super.key,
  });

  @override
  createState() => _State();
}

class _State extends State<Viewer> {
  double scale = 0;
  final TransformationController transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    scale = transformationController.value.getMaxScaleOnAxis();
  }

  @override
  build(context) {
    return InteractiveViewer(
      minScale: widget.minScale,
      maxScale: widget.maxScale,
      transformationController: transformationController,
      onInteractionEnd: (details) => setState(() {
        scale = transformationController.value.getMaxScaleOnAxis();
      }),
      child: widget.builder(scale),
    );
  }
}
