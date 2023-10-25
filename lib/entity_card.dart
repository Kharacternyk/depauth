import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'core/edit_subject.dart';
import 'core/entity_insight.dart';
import 'core/position.dart';
import 'core/traversable_entity.dart';
import 'entity_theme.dart';
import 'widget_extension.dart';

class EntityCard extends StatelessWidget {
  final TraversableEntity entity;
  final ValueNotifier<EditSubject> editSubject;
  final EntityInsight insight;
  final Position position;

  const EntityCard(
    this.entity, {
    required this.editSubject,
    required this.insight,
    required this.position,
    super.key,
  });

  @override
  build(context) {
    const padding = EdgeInsets.all(8);
    const spacer = Spacer();
    const spacer2 = Spacer(flex: 2);

    final colors = Theme.of(context).colorScheme;
    final messages = AppLocalizations.of(context)!;
    final dependencyIcons = <Widget>[];

    for (final factor in entity.factors) {
      for (final dependency in factor.dependencies) {
        dependencyIcons.add(
          dependency.type
              .pointingBanner(
                name: [
                  factor.identity,
                  dependency.identity,
                ].join(messages.arrowIdentitySeparator),
                target: dependency.identity.toString(),
              )
              .expand()
              .keyed(ValueKey((factor.identity, dependency.identity))),
        );
      }
      dependencyIcons.add(
        const Icon(Icons.add).pad(padding).fit.grow.expand(),
      );
    }

    if (dependencyIcons.isNotEmpty) {
      dependencyIcons.removeLast();
    }

    final lost = insight.loss != null;
    final compromised = insight.compromise != null;
    final importance = insight.importance.boostedValue.clamp(0, 3);
    final lostIcon = Icon(
      Icons.not_listed_location,
      color: colors.onError,
    ).fit.grow;
    final compromisedIcon = Icon(
      Icons.report,
      color: colors.onError,
    ).fit.grow;

    return [
      spacer,
      [
        [
          spacer,
          if (importance > 0)
            [
              Spacer(flex: 6 - importance),
              entity.type.starRibbon(importance).expand(2 * importance),
              Spacer(flex: 6 - importance),
            ].column.expand(),
        ].row.expand(),
        ArrowElement(
          id: entity.identity.toString(),
          child: Card(
            elevation: 10,
            margin: EdgeInsets.zero,
            shape: const Border(),
            child: InkWell(
              onTap: () {
                editSubject.value = EntitySubject(position);
              },
              child: [
                if (entity.factors.isNotEmpty) dependencyIcons.row.expand(),
                Text(entity.name).pad(padding).fit.expand(),
                entity.type.banner.expand(),
              ].column,
            ),
          ),
        ).expand(6),
        [
          insight.ancestorCount > 0
              ? [
                  Material(
                    color: colors.surfaceVariant,
                    child: [
                      Icon(Icons.arrow_upward, color: colors.onSurfaceVariant)
                          .fit
                          .expand(),
                      Text(
                        insight.ancestorCount.toString(),
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
          ...switch ((lost, compromised)) {
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
          insight.descendantCount > 0
              ? [
                  Material(
                    color: colors.surfaceVariant,
                    child: [
                      Icon(Icons.arrow_downward, color: colors.onSurfaceVariant)
                          .fit
                          .expand(),
                      Text(
                        insight.descendantCount.toString(),
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ).fit.expand(),
                    ].row,
                  ).grow.expand(),
                  spacer,
                ].row.expand()
              : spacer,
        ].column.expand(),
      ].row.expand(6),
      spacer,
    ].column;
  }
}
