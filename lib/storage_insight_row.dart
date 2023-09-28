import 'package:flutter/material.dart';

import 'core/storage_insight.dart';
import 'widget_extension.dart';

class StorageInsightRow extends StatelessWidget {
  final StorageInsight insight;

  const StorageInsightRow(this.insight, {super.key});

  @override
  build(context) {
    final colors = Theme.of(context).colorScheme;

    return Ink(
      color: colors.surfaceVariant,
      padding: const EdgeInsets.all(4),
      child: [
        Icon(
          Icons.style,
          color: colors.onSurfaceVariant,
        ).fit.expand(),
        Text(
          insight.entityCount.toString(),
          style: TextStyle(color: colors.onSurfaceVariant),
        ).fit.expand(),
      ].column,
    );
  }
}
