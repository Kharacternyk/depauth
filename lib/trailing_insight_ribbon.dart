import 'package:flutter/material.dart';

import 'core/edit_subject.dart';
import 'core/entity_insight.dart';
import 'core/position.dart';
import 'widget_extension.dart';

class TrailingInsightRibbon extends StatelessWidget {
  final EntityInsight insight;
  final ValueNotifier<EditSubject> editSubject;
  final Position position;

  const TrailingInsightRibbon(
    this.insight,
    this.editSubject,
    this.position, {
    super.key,
  });

  @override
  build(context) {
    const spacer = Spacer();
    const spacer2 = Spacer(flex: 2);
    final colors = Theme.of(context).colorScheme;

    late final lostIcon = Icon(
      Icons.not_listed_location,
      color: colors.onError,
    ).fit.grow;
    late final compromisedIcon = Icon(
      Icons.report,
      color: colors.onError,
    ).fit.grow;

    return [
      insight.dependencyCount > 0
          ? [
              Material(
                color: colors.surfaceVariant,
                child: [
                  Icon(Icons.arrow_upward, color: colors.onSurfaceVariant)
                      .fit
                      .expand(),
                  Text(
                    insight.dependencyCount.toString(),
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ).fit.expand(),
                ].row,
              ).grow.expand(),
              spacer,
            ].row.expand()
          : spacer,
      (EditSubject subject) {
        if (subject case EntitySubject subject
            when subject.position == position) {
          return Material(
            color: colors.secondary,
            child: Icon(
              Icons.edit,
              color: colors.onSecondary,
            ).fit.grow,
          ).expand(2);
        }
        return spacer2;
      }.listen(editSubject),
      ...switch ((!insight.reachability.present, insight.compromise.present)) {
        (true, true) => [
            Material(
              color: colors.error,
              child: [
                lostIcon.expand(),
                compromisedIcon.expand(),
              ].column,
            ).expand(4)
          ],
        (true, _) => [
            Material(
              color: colors.error,
              child: lostIcon,
            ).expand(2),
            spacer2
          ],
        (_, true) => [
            spacer2,
            Material(
              color: colors.error,
              child: compromisedIcon,
            ).expand(2),
          ],
        _ => [const Spacer(flex: 4)],
      },
      insight.dependantCount > 0
          ? [
              Material(
                color: colors.surfaceVariant,
                child: [
                  Icon(Icons.arrow_downward, color: colors.onSurfaceVariant)
                      .fit
                      .expand(),
                  Text(
                    insight.dependantCount.toString(),
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ).fit.expand(),
                ].row,
              ).grow.expand(),
              spacer,
            ].row.expand()
          : spacer,
    ].column;
  }
}
