import 'package:flutter/material.dart';

import 'core/storage_insight.dart';
import 'widget_extension.dart';

class StorageInsightRow extends StatelessWidget {
  final StorageInsight insight;

  const StorageInsightRow(this.insight, {super.key});

  @override
  build(context) {
    final colors = Theme.of(context).colorScheme;
    const padding = EdgeInsets.all(4);

    return IconTheme(
      data: IconThemeData(color: colors.onSurfaceVariant),
      child: Ink(
        color: colors.surfaceVariant,
        child: [
          if (insight.entityCount > 0)
            [
              const Icon(Icons.style).fit.expand(),
              Text(
                insight.entityCount.toString(),
                style: TextStyle(color: colors.onSurfaceVariant),
              ).fit.expand(),
            ].column.pad(padding),
          if (insight.lostEntityCount > 0)
            [
              const Icon(Icons.not_listed_location).fit.expand(),
              Text(
                insight.lostEntityCount.toString(),
                style: TextStyle(color: colors.onSurfaceVariant),
              ).fit.expand(),
            ].column.pad(padding),
          if (insight.compromisedEntityCount > 0)
            [
              const Icon(Icons.report).fit.expand(),
              Text(
                insight.compromisedEntityCount.toString(),
                style: TextStyle(color: colors.onSurfaceVariant),
              ).fit.expand(),
            ].column.pad(padding),
        ].row,
      ),
    );
  }
}
