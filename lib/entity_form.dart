import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'card_dropdown.dart';
import 'card_form.dart';
import 'core/active_record.dart';
import 'core/entity.dart';
import 'core/entity_insight.dart';
import 'core/importance_boost.dart';
import 'core/interleave.dart';
import 'core/storage.dart';
import 'core/title_case.dart';
import 'core/traveler.dart';
import 'core/traversable_entity.dart';
import 'debounced_text_field.dart';
import 'entity_chip.dart';
import 'entity_theme.dart';
import 'scaled_draggable.dart';
import 'trait_switch.dart';
import 'widget_extension.dart';

class EntityForm extends StatelessWidget {
  final TraversableEntity entity;
  final ActiveRecord storage;
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
    final factorCards = <Widget>[];

    for (final factor in entity.factors) {
      final dependencies = <Widget>[
        for (final dependency in factor.dependencies)
          ScaledDraggable(
            key: ValueKey(dependency.identity),
            needsMaterial: true,
            dragData: DependencyTraveler(dependency.passport),
            child: dependency.chip,
          )
      ];

      final card = DragTarget<DependableTraveler>(
        key: ValueKey(factor.identity),
        onWillAccept: (traveler) {
          if (traveler case FactorTraveler traveler
              when traveler.passport.identity == factor.identity) {
            return false;
          }

          return factor.passport.entity.identity != traveler?.entity;
        },
        onAccept: (traveler) {
          final travelingEntity = traveler.entity;

          if (travelingEntity != null && factor.contains(travelingEntity)) {
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
            case FactorTraveler traveler:
              storage.mergeFactors(factor.passport, traveler.passport);
          }
        },
        builder: (context, candidate, rejected) {
          final willAccept = candidate.any((traveler) {
            if (traveler == null) {
              return false;
            }
            final travelingEntity = traveler.entity;

            if (travelingEntity != null && factor.contains(travelingEntity)) {
              return false;
            }

            return true;
          });

          return ScaledDraggable(
            dragData: FactorTraveler(factor.passport),
            child: Card(
              color: willAccept ? colors.primaryContainer : null,
              child: ListTile(
                mouseCursor: willAccept
                    ? SystemMouseCursors.copy
                    : SystemMouseCursors.grab,
                title: dependencies.isEmpty
                    ? Text(messages.emptyFactorTip)
                    : dependencies.wrap,
                leading: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    items: [
                      for (var i = 5; i >= 1; --i)
                        DropdownMenuItem(
                          value: i,
                          child: Text(messages.anyOf(i)),
                        ),
                      if (factor.threshold.clamp(1, 5) != factor.threshold)
                        DropdownMenuItem(
                          value: factor.threshold,
                          child: Text(messages.anyOf(factor.threshold)),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        storage.changeThreshold(factor.passport, value);
                      }
                    },
                    value: factor.threshold,
                  ),
                ),
              ),
            ),
          );
        },
      );

      factorCards.add(card);
    }

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
          getInitialValue: () => entity.name,
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
              if (type != null) {
                storage.changeType(entity.passport, type);
              }
            },
            value: entity.type,
          ),
        ),
      ).card,
      CardDropdown(
        leading: const Icon(Icons.edit_note),
        title: Text(entity.note == null ? messages.addNote : messages.showNote),
        children: [
          ListTile(
            title: DebouncedTextField(
              key: ValueKey(entity.identity),
              getInitialValue: () => entity.note ?? '',
              delay: const Duration(milliseconds: 200),
              commitValue: (note) {
                final trimmed = note.trim();
                final currentNote = entity.note;

                if (currentNote != null) {
                  if (trimmed.isNotEmpty) {
                    storage.changeNote(entity.passport, trimmed);
                  } else {
                    storage.removeNote(entity.passport);
                  }
                } else if (trimmed.isNotEmpty) {
                  storage.addNote(entity.passport, trimmed);
                }
              },
              hint: messages.note,
              isCanceled: () => storage.disposed,
              multiline: true,
            ),
          ),
        ],
      ).card,
      [
        ListTile(
          leading: const Icon(Icons.star),
          title: SegmentedButton<int>(
            selected: {insight.importance.value},
            segments: [
              for (var importance = 0; importance <= 3; ++importance)
                ButtonSegment(
                  value: importance,
                  label: Text(importance.toString()),
                )
            ],
            onSelectionChanged: (selection) {
              storage.changeImportance(entity.passport, selection.first);
            },
            showSelectedIcon: false,
          ),
        ),
        if (insight.importance.boost
            case ImportanceBoost<Identity<Entity>> boost)
          ListTile(
            leading: const Icon(Icons.upgrade),
            title: [
              Text(
                [insight.importance.boostedValue, messages.becauseOf].join(),
              ),
              if (storage.getPassportlessEntity(boost.origin)
                  case Entity entity)
                entity.chip
            ].wrap,
          ),
      ].column.card,
      TraitSwitch(
        insight.loss,
        storage: storage,
        icon: const Icon(Icons.not_listed_location),
        toggle: (value) => storage.toggleLost(entity.passport, value),
        name: messages.lost,
      ),
      TraitSwitch(
        insight.compromise,
        storage: storage,
        icon: const Icon(Icons.report),
        toggle: (value) => storage.toggleCompromised(entity.passport, value),
        name: messages.compromised,
      ),
      ListTile(
        title: Text(
          entity.factors.isEmpty
              ? messages.noFactorsTip(typeName)
              : messages.accessTip(typeName),
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      ),
      ...factorCards.interleave(
        ListTile(
          title: Text(
            messages.and,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ),
      )
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
