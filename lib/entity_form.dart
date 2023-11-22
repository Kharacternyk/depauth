import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'card_dropdown.dart';
import 'card_form.dart';
import 'core/access.dart';
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
                leading: DropdownButton(
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
        title: DropdownButton(
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
                [
                  insight.importance.boostedValue,
                  messages.wordSeparator,
                  messages.becauseOf,
                ].join(),
              ),
              if (storage.getPassportlessEntity(boost.origin)
                  case Entity entity)
                entity.chip
            ].wrap,
          ),
      ].column.card,
      [
        SwitchListTile(
          title: Text(switch (insight.reachability) {
            DerivedAccess<Identity<Entity>> access when access.present =>
              messages.reachableThrough,
            OriginAccess<Identity<Entity>> _ => messages.reachable,
            _ => messages.notReachable,
          }),
          activeColor: colors.error,
          value: insight.reachability is BlockedAccess,
          selected: !insight.reachability.present,
          secondary: insight.reachability.present
              ? const Icon(Icons.where_to_vote)
              : const Icon(Icons.not_listed_location),
          onChanged: (value) {
            storage.toggleLost(entity.passport, value);
          },
        ),
        if (insight.reachability case DerivedAccess<Identity<Entity>> access
            when access.present)
          ListTile(
            leading: const Icon(Icons.link),
            title: access.derivedFrom
                .map(storage.getPassportlessEntity)
                .nonNulls
                .map((entity) => entity.chip)
                .toList()
                .wrap,
          )
      ].column.card,
      [
        SwitchListTile(
          title: Text(switch (insight.compromise) {
            DerivedAccess<Identity<Entity>> access when access.present =>
              messages.compromisedThrough,
            OriginAccess<Identity<Entity>> _ => messages.compromised,
            _ => messages.notCompromised,
          }),
          activeColor: colors.error,
          value: insight.compromise is OriginAccess,
          selected: insight.compromise.present,
          secondary: insight.compromise.present
              ? const Icon(Icons.report)
              : const Icon(Icons.report_off),
          onChanged: (value) {
            storage.toggleCompromised(entity.passport, value);
          },
        ),
        if (insight.compromise case DerivedAccess<Identity<Entity>> access
            when access.present)
          ListTile(
            iconColor: colors.error,
            leading: const Icon(Icons.link),
            title: access.derivedFrom
                .map(storage.getPassportlessEntity)
                .nonNulls
                .map((entity) => entity.chip)
                .toList()
                .wrap,
          )
      ].column.card,
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
