import 'package:flutter/material.dart';

import 'fractional_spacer.dart';
import 'logotype.dart';
import 'view_region.dart';
import 'widget_extension.dart';

class ViewRegionIndicator extends StatelessWidget {
  final ViewRegion region;

  const ViewRegionIndicator(this.region, {super.key});

  @override
  build(context) {
    final invertedScale = 1 / region.scale;

    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.primaryContainer,
      elevation: 0,
      child: AspectRatio(
        aspectRatio: region.aspectRatio,
        child: [
          FractionalSpacer(region.relativeOffset.dx),
          FractionalSpacer(
            invertedScale,
            child: [
              FractionalSpacer(region.relativeOffset.dy),
              FractionalSpacer(
                invertedScale,
                child: const Logotype(),
              ),
              FractionalSpacer(1 - region.relativeOffset.dy - invertedScale),
            ].column,
          ),
          FractionalSpacer(1 - region.relativeOffset.dx - invertedScale),
        ].row,
      ).pad(const EdgeInsets.all(8)),
    );
  }
}
