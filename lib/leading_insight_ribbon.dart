import 'package:flutter/material.dart';

import 'core/entity_insight.dart';
import 'core/entity_type.dart';
import 'entity_theme.dart';
import 'widget_extension.dart';

class LeadingInsightRibbon extends StatelessWidget {
  final EntityType type;
  final EntityInsight insight;

  const LeadingInsightRibbon(this.insight, this.type, {super.key});

  @override
  build(context) {
    final importance = insight.importance.boostedValue.clamp(0, 3);

    if (importance == 0) {
      return const SizedBox.shrink();
    }

    return [
      const Spacer(),
      [
        Spacer(flex: 6 - importance),
        type.starRibbon(importance).expand(2 * importance),
        Spacer(flex: 6 - importance),
      ].column.expand(),
    ].row;
  }
}
