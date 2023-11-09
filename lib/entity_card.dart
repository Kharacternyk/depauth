import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';
import 'package:widget_arrows/widget_arrows.dart';

import 'core/edit_subject.dart';
import 'core/entity_insight_origin.dart';
import 'core/title_case.dart';
import 'core/traversable_entity.dart';
import 'entity_theme.dart';
import 'leading_insight_ribbon.dart';
import 'trailing_insight_ribbon.dart';
import 'widget_extension.dart';

class EntityCard extends StatelessWidget {
  final TraversableEntity entity;
  final ValueNotifier<EditSubject> editSubject;
  final EntityInsightOrigin insightOrigin;

  const EntityCard(
    this.entity, {
    required this.editSubject,
    required this.insightOrigin,
    super.key,
  });

  @override
  build(context) {
    const padding = EdgeInsets.all(8);
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
              .tip(dependency.name, 20)
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

    return [
      const Spacer(),
      [
        () {
          return LeadingInsightRibbon(
            insightOrigin.getEntityInsight(entity.identity),
            entity,
          );
        }.listen(insightOrigin.entityInsightNotifier).expand(),
        ArrowElement(
          id: entity.identity.toString(),
          child: Card(
            elevation: 10,
            margin: EdgeInsets.zero,
            shape: const Border(),
            child: InkWell(
              onTap: () {
                editSubject.value = EntitySubject(entity.passport.position);
              },
              child: [
                if (entity.factors.isNotEmpty) dependencyIcons.row.expand(),
                Text(entity.name).pad(padding).fit.expand(),
                entity.type.banner
                    .tip([
                      entity.name,
                      messages.duplicatePrefix,
                      entity.type.name(messages).title(messages.wordSeparator),
                      messages.duplicateSuffix,
                    ].join())
                    .expand(),
              ].column,
            ),
          ),
        ).expand(6),
        () {
          return TrailingInsightRibbon(
            insightOrigin.getEntityInsight(entity.identity),
            editSubject,
            entity.passport.position,
          );
        }.listen(insightOrigin.entityInsightNotifier).expand(),
      ].row.expand(6),
      const Spacer(),
    ].column;
  }
}
