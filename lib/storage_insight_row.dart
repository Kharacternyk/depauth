import 'package:flutter/material.dart';

import 'core/storage_insight.dart';
import 'icon_number_column.dart';
import 'widget_extension.dart';

class StorageInsightRow extends StatelessWidget {
  final StorageInsight insight;

  const StorageInsightRow(this.insight, {super.key});

  @override
  build(context) {
    final colors = Theme.of(context).colorScheme;

    return IconTheme(
      data: IconThemeData(color: colors.onSurfaceVariant),
      child: Ink(
        color: colors.surfaceVariant,
        child: [
          IconNumberColumn(const Icon(Icons.style), insight.entityCount),
          IconNumberColumn(const Icon(Icons.edit_note), insight.noteCount),
          IconNumberColumn(const Icon(Icons.star), insight.totalImportance),
          IconNumberColumn(
            const Icon(Icons.not_listed_location),
            insight.lostEntityCount,
          ),
          IconNumberColumn(
            const Icon(Icons.report),
            insight.compromisedEntityCount,
          ),
        ].row,
      ),
    );
  }
}
