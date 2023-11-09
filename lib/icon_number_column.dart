import 'package:flutter/material.dart';

import 'widget_extension.dart';

class IconNumberColumn extends StatelessWidget {
  final Icon icon;
  final int number;

  const IconNumberColumn(this.icon, this.number, {super.key});

  @override
  build(context) {
    if (number <= 0) {
      return const SizedBox.shrink();
    }

    final colors = Theme.of(context).colorScheme;

    return [
      icon.fit.expand(),
      Text(number.toString(), style: TextStyle(color: colors.onSurfaceVariant))
          .fit
          .expand(),
    ].column.pad(const EdgeInsets.all(4));
  }
}
