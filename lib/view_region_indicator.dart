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

    return Ink(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: AspectRatio(
        aspectRatio: region.aspectRatio.clamp(.5, 2),
        child: [
          FractionalSpacer(region.relativeOffset.dx),
          FractionalSpacer(
            invertedScale,
            child: [
              FractionalSpacer(region.relativeOffset.dy),
              FractionalSpacer(
                invertedScale,
                child: [
                  const Spacer(),
                  [
                    const Spacer(),
                    const Logotype().expand(6),
                    const Spacer(),
                  ].column.expand(6),
                  const Spacer(),
                ].row,
              ),
              FractionalSpacer(1 - region.relativeOffset.dy - invertedScale),
            ].column,
          ),
          FractionalSpacer(1 - region.relativeOffset.dx - invertedScale),
        ].row,
      ),
    );
  }
}
