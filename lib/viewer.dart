import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'scale.dart';
import 'view_region.dart';

class Viewer extends StatefulWidget {
  final Widget child;
  final double minScale;
  final double maxScale;
  final ValueNotifier<ViewRegion> region;

  const Viewer({
    required this.child,
    required this.minScale,
    required this.maxScale,
    required this.region,
    super.key,
  });

  @override
  createState() => _State();
}

class _State extends State<Viewer> {
  final key = GlobalKey();
  final transformationController = TransformationController();
  late var scale = transformationController.value.getMaxScaleOnAxis();

  @override
  dispose() {
    transformationController.dispose();
    super.dispose();
  }

  @override
  build(context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      updateViewRegion();
    });

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (SizeChangedLayoutNotification notification) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          updateViewRegion();
        });
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: InteractiveViewer(
          key: key,
          minScale: widget.minScale,
          maxScale: widget.maxScale,
          transformationController: transformationController,
          onInteractionEnd: (details) {
            setState(() {
              scale = transformationController.value.getMaxScaleOnAxis();
            });
            updateViewRegion();
          },
          child: Scale(scale, child: widget.child),
        ),
      ),
    );
  }

  void updateViewRegion() {
    if (key.currentContext?.findRenderObject() case RenderBox box) {
      final origin = transformationController.toScene(Offset.zero);

      widget.region.value = ViewRegion(
        aspectRatio: box.size.aspectRatio,
        scale: scale,
        relativeOffset: Offset(
          origin.dx / box.size.width,
          origin.dy / box.size.height,
        ),
      );
    }
  }
}
