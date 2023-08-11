import 'package:flutter/material.dart';

import 'core/boundaries.dart';
import 'core/position.dart';

class BoundaryIcon extends StatelessWidget {
  final Boundaries boundaries;
  final Position position;

  const BoundaryIcon(this.boundaries, this.position, {super.key});

  @override
  build(context) {
    return Icon(switch ((
      (position.x - boundaries.end.x, position.y - boundaries.end.y),
      (boundaries.start.x - position.x, boundaries.start.y - position.y)
    )) {
      ((0, 0), (0, 0)) => null,
      ((0, 0), _) => Icons.south_east,
      (_, (0, 0)) => Icons.north_west,
      ((_, 0), (0, _)) => Icons.south_west,
      ((0, _), (_, 0)) => Icons.north_east,
      ((_, 0), _) => Icons.south,
      ((0, _), _) => Icons.east,
      (_, (_, 0)) => Icons.north,
      (_, (0, _)) => Icons.west,
      _ => null,
    });
  }
}
