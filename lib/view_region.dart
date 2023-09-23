import 'package:flutter/material.dart';

class ViewRegion {
  final double aspectRatio;
  final double scale;
  final Offset relativeOffset;

  const ViewRegion({
    required this.aspectRatio,
    this.scale = 1,
    this.relativeOffset = Offset.zero,
  });

  @override
  operator ==(other) =>
      other is ViewRegion &&
      aspectRatio == other.aspectRatio &&
      scale == other.scale &&
      relativeOffset == other.relativeOffset;

  @override
  int get hashCode => Object.hash(scale, relativeOffset);
}
