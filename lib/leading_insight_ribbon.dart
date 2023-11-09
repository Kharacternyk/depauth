import 'package:flutter/material.dart';

import 'core/entity_insight.dart';
import 'core/traversable_entity.dart';
import 'entity_theme.dart';
import 'widget_extension.dart';

class LeadingInsightRibbon extends StatelessWidget {
  final EntityInsight insight;
  final TraversableEntity entity;

  const LeadingInsightRibbon(this.insight, this.entity, {super.key});

  @override
  build(context) {
    final importance = insight.importance.boostedValue.clamp(0, 3);
    final note = entity.note;

    return [
      const Spacer(),
      [
        Spacer(flex: 6 - importance),
        if (importance > 0)
          entity.type.starRibbon(importance).expand(2 * importance),
        Spacer(flex: 4 - importance),
        note != null
            ? entity.type.noteBadge.tip(note).expand(2)
            : const Spacer(flex: 2),
      ].column.expand(),
    ].row;
  }
}
