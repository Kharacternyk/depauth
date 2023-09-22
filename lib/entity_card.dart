import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'core/edit_subject.dart';
import 'core/entity_insight.dart';
import 'core/position.dart';
import 'core/traversable_entity.dart';
import 'entity_icon.dart';
import 'entity_theme.dart';
import 'scaled_line.dart';
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
    final colors = Theme.of(context).colorScheme;
    final messages = AppLocalizations.of(context)!;
    final dependencyIcons = <Widget>[];

    for (final factor in entity.factors) {
      for (final dependency in factor.dependencies) {
        dependencyIcons.add(
          ScaledLine(
            name: [
              factor.identity,
              dependency.identity,
            ].join(messages.arrowIdentitySeparator),
            color: EntityTheme(dependency.type).primary.withOpacity(0.5),
            targetName: dependency.identity.toString(),
            child: EntityIcon(
              dependency.type,
              padding: padding,
            ),
          ).expand().keyed(ValueKey((factor.identity, dependency.identity))),
        );
      }
      dependencyIcons.add(
        const Icon(Icons.add).pad(padding).fit.grow.expand(),
      );
    }

    if (dependencyIcons.isNotEmpty) {
      dependencyIcons.removeLast();
    }

    final lost = insight.hasLostFactor || entity.lost;
    final compromised = insight.areAllFactorsCompromised || entity.compromised;
    final lostIcon = Icon(
      Icons.not_listed_location,
      color: colors.onError,
    ).fit.grow;
    final compromisedIcon = Icon(
      Icons.report,
      color: colors.onError,
    ).fit.grow;

    return [
      const Spacer(),
      [
        const Spacer(),
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
                EntityIcon(
                  entity.type,
                  padding: padding,
                ).expand(),
              ].column,
            ),
          ),
        ).expand(6),
        [
          (EditSubject subject) {
            if (subject case EntitySubject subject
                when subject.position == position) {
              return Material(
                color: colors.secondary,
                child: Icon(
                  Icons.edit,
                  color: colors.onSecondary,
                ).fit.grow,
              ).expand();
            }
            return const Spacer();
          }.listen(editSubject),
          ...switch ((lost, compromised)) {
            (true, true) => [
                Material(
                  color: colors.error,
                  child: [
                    lostIcon,
                    compromisedIcon,
                  ].column,
                ).expand(2)
              ],
            (true, _) => [
                Material(
                  color: colors.error,
                  child: lostIcon,
                ).expand(),
                const Spacer()
              ],
            (_, true) => [
                const Spacer(),
                Material(
                  color: colors.error,
                  child: compromisedIcon,
                ).expand(),
              ],
            _ => [
                const Spacer(flex: 2),
              ],
          },
          const Spacer(flex: 1),
        ].column.expand(),
      ].row.expand(6),
      const Spacer(),
    ].column;
  }
}
