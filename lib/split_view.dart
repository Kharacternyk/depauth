import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';

class SplitView extends StatelessWidget {
  final Widget mainChild;
  final Widget sideChild;

  const SplitView({
    required this.mainChild,
    required this.sideChild,
    super.key,
  });

  @override
  build(context) {
    final colors = Theme.of(context).colorScheme;

    return MultiSplitViewTheme(
      data: MultiSplitViewThemeData(
        dividerPainter: DividerPainters.grooved1(
          backgroundColor: colors.surfaceVariant,
          color: colors.onSurfaceVariant,
          highlightedColor: colors.primary,
        ),
      ),
      child: MultiSplitView(
        axis: switch (MediaQuery.of(context).orientation) {
          Orientation.portrait => Axis.vertical,
          Orientation.landscape => Axis.horizontal,
        },
        initialAreas: [Area(weight: 0.7)],
        children: [mainChild, sideChild],
      ),
    );
  }
}
