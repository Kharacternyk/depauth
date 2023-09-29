import 'package:flutter/material.dart';

import 'core/storage_insight.dart';
import 'widget_extension.dart';

class StorageInsightRow extends StatelessWidget {
  final StorageInsight insight;

  const StorageInsightRow(this.insight, {super.key});

  @override
  build(context) {
    final colors = Theme.of(context).colorScheme;
    print(insight.lostEntityCount);

    return [
      if (insight.entityCount > 0)
        Ink(
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
        ),
      Ink(
        color: colors.errorContainer,
        child: [
          if (insight.lostEntityCount > 0)
            [
              Icon(
                Icons.not_listed_location,
                color: colors.onErrorContainer,
              ).fit.expand(),
              Text(
                insight.lostEntityCount.toString(),
                style: TextStyle(color: colors.onErrorContainer),
              ).fit.expand(),
            ].column.pad(const EdgeInsets.all(4)),
          if (insight.compromisedEntityCount > 0)
            [
              Icon(
                Icons.report,
                color: colors.onErrorContainer,
              ).fit.expand(),
              Text(
                insight.compromisedEntityCount.toString(),
                style: TextStyle(color: colors.onErrorContainer),
              ).fit.expand(),
            ].column.pad(const EdgeInsets.all(4)),
        ].row,
      ),
    ].row;
  }
}
