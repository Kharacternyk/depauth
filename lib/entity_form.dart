import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'card_form.dart';
import 'core/active_record_storage.dart';
import 'core/entity_insight.dart';
import 'core/entity_type.dart';
import 'core/interleave.dart';
import 'core/title_case.dart';
import 'core/traveler.dart';
import 'core/traversable_entity.dart';
import 'debounced_text_field.dart';
import 'entity_theme.dart';
import 'scaled_draggable.dart';
import 'widget_extension.dart';

class EntityForm extends StatelessWidget {
  final TraversableEntity entity;
  final ActiveRecordStorage storage;
  final EntityInsight insight;
  final ValueNotifier<bool> hasTraveler;
  final void Function() goBack;

  const EntityForm(
    this.entity, {
    required this.storage,
    required this.hasTraveler,
    required this.goBack,
    required this.insight,
    super.key,
  });

  @override
  build(context) {
    final colors = Theme.of(context).colorScheme;
    final messages = AppLocalizations.of(context)!;
    final typeName = entity.type.name(messages);

    final form = CardForm([
      ListTile(
        leading: const BackButtonIcon(),
        title: Text(messages.back),
        onTap: goBack,
      ).card,
      ListTile(
        leading: const Icon(Icons.edit),
        title: DebouncedTextField(
          key: ValueKey(entity.identity),
          value: entity.name,
          delay: const Duration(milliseconds: 200),
          commitValue: (name) {
            storage.changeName(entity.passport, name);
          },
          hint: messages.name,
          isCanceled: () => storage.disposed,
        ),
      ).card,
      ListTile(
        leading: const Icon(Icons.category),
        title: DropdownButtonHideUnderline(
          child: DropdownButton(
            isExpanded: true,
            items: [
              for (final type in EntityTheme.knownTypes)
                DropdownMenuItem(
                  value: type,
                  child: type
                      .chip(type.name(messages).title(messages.wordSeparator)),
                ),
            ],
            onChanged: (type) {
              if (type case EntityType type) {
                storage.changeType(entity.passport, type);
              }
            },
            value: entity.type,
          ),
        ),
      ).card,
      ListTile(
        leading: const Icon(Icons.star),
        title: SegmentedButton<int>(
          selected: {entity.importance},
          segments: [
            for (var importance = 0; importance <= 5; ++importance)
              ButtonSegment(
                value: importance,
                label: importance >= insight.bubbledImportance
                    ? Text(importance.toString())
                    : null,
                icon: importance < insight.bubbledImportance
                    ? const Icon(Icons.close).fit
                    : null,
              )
          ],
          onSelectionChanged: (selection) {
            storage.changeImportance(entity.passport, selection.first);
          },
          showSelectedIcon: false,
        ),
      ).card,
      SwitchListTile(
        title: Text(
          insight.hasLostFactor
              ? messages.automaticallyLost(typeName)
              : messages.lost,
        ),
        activeColor: colors.error,
        value: entity.lost,
        selected: insight.hasLostFactor || entity.lost,
        secondary: const Icon(Icons.not_listed_location),
        onChanged: (value) {
          storage.toggleLost(entity.passport, value);
        },
      ).card,
      SwitchListTile(
        title: Text(
          insight.areAllFactorsCompromised
              ? messages.automaticallyCompromised(typeName)
              : messages.compromised,
        ),
        activeColor: colors.error,
        value: entity.compromised,
        selected: entity.compromised || insight.areAllFactorsCompromised,
        secondary: const Icon(Icons.report),
        onChanged: (value) {
          storage.toggleCompromised(entity.passport, value);
        },
      ).card,
      ListTile(
        title: Text(
          entity.factors.isEmpty
              ? messages.noFactorsTip(typeName)
              : messages.accessTip(typeName),
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      ),
      ...<Widget>[
        for (final factor in entity.factors)
          DragTarget<DependableTraveler>(
            key: ValueKey(factor.identity),
            onWillAccept: (traveler) {
              return factor.passport.entity.identity != traveler?.entity;
            },
            onAccept: (traveler) {
              if (factor.contains(traveler.entity)) {
                return;
              }

              switch (traveler) {
                case EntityTraveler traveler:
                  storage.addDependency(
                    factor.passport,
                    traveler.passport.identity,
                  );
                case DependencyTraveler traveler:
                  storage.moveDependency(traveler.passport, factor.passport);
              }
            },
            builder: (context, candidate, rejected) {
              return ScaledDraggable(
                dragData: FactorTraveler(factor.passport),
                child: Card(
                  color: candidate.any((traveler) {
                    return traveler != null &&
                        !factor.contains(traveler.entity);
                  })
                      ? colors.primaryContainer
                      : null,
                  child: ListTile(
                    mouseCursor: candidate.isNotEmpty
                        ? SystemMouseCursors.copy
                        : SystemMouseCursors.grab,
                    leading: const Icon(Icons.link),
                    title: factor.dependencies.isNotEmpty
                        ? Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              for (final dependency in factor.dependencies)
                                ScaledDraggable(
                                  key: ValueKey(dependency.identity),
                                  needsMaterial: true,
                                  dragData:
                                      DependencyTraveler(dependency.passport),
                                  child: dependency.type.chip(dependency.name),
                                ),
                            ].interleave(Text(messages.or)).toList(),
                          )
                        : Text(messages.emptyFactorTip),
                  ),
                ),
              );
            },
          ),
      ]
          .interleave(
            ListTile(
              title: Text(
                messages.and,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ),
          )
          .toList(),
    ]);

    return DragTarget<FactorableTraveler>(
      builder: (context, candidate, rejected) => form,
      onWillAccept: (traveler) {
        if (traveler case EntityTraveler traveler
            when traveler.passport.identity == entity.identity) {
          return false;
        }
        return hasTraveler.value = true;
      },
      onLeave: (_) => hasTraveler.value = false,
      onAccept: (traveler) {
        hasTraveler.value = false;
        switch (traveler) {
          case CreationTraveler _:
            storage.addFactor(entity.passport);
          case EntityTraveler traveler:
            storage.addDependencyAsFactor(
              entity.passport,
              traveler.passport.identity,
            );
          case DependencyTraveler traveler:
            storage.moveDependencyAsFactor(traveler.passport, entity.passport);
        }
      },
    );
  }
}
