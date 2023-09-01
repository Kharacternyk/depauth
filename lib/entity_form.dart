import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'card_form.dart';
import 'core/entity.dart';
import 'core/entity_insight.dart';
import 'core/entity_type.dart';
import 'core/enumerate.dart';
import 'core/factor.dart';
import 'core/interleave.dart';
import 'core/position.dart';
import 'core/storage.dart';
import 'core/traveler.dart';
import 'core/traversable_entity.dart';
import 'debounced_text_field.dart';
import 'entity_theme.dart';
import 'entity_type_name.dart';
import 'scaled_draggable.dart';
import 'tip.dart';
import 'widget_extension.dart';

class EntityForm extends StatelessWidget {
  final TraversableEntity entity;
  final Position position;
  final EntityInsight insight;
  final ValueNotifier<bool> hasTraveler;
  final void Function() goBack;
  final void Function(String) changeName;
  final void Function(EntityType) changeType;
  final void Function(bool) toggleLost;
  final void Function(bool) toggleCompromised;
  final void Function() addFactor;
  final void Function(Identity<Entity>) addDependencyAsFactor;
  final void Function(Identity<Factor>, Identity<Entity>) addDependency;
  final void Function(Identity<Factor>, Identity<Entity>) removeDependency;

  const EntityForm(
    this.entity, {
    required this.hasTraveler,
    required this.goBack,
    required this.insight,
    required this.position,
    required this.changeName,
    required this.changeType,
    required this.toggleLost,
    required this.toggleCompromised,
    required this.addFactor,
    required this.addDependencyAsFactor,
    required this.addDependency,
    required this.removeDependency,
    super.key,
  });

  @override
  build(context) {
    final colors = Theme.of(context).colorScheme;
    final messages = AppLocalizations.of(context)!;

    final children = [
      ListTile(
        leading: const BackButtonIcon(),
        title: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            Chip(
              avatar: const Icon(Icons.arrow_upward),
              label: Text(insight.ancestorCount.toString()),
            ).tip(messages.ancestorCount),
            Chip(
              avatar: const Icon(Icons.arrow_downward),
              label: Text(insight.descendantCount.toString()),
            ).tip(messages.descendantCount),
            Chip(
              avatar: const Icon(Icons.swap_vert),
              label: Text(
                '${(insight.coupling * 100).toStringAsFixed(0)}%',
              ),
            ).tip(messages.couplingTooltip),
          ],
        ),
        onTap: goBack,
      ).card,
      ListTile(
        leading: const Icon(Icons.edit),
        title: DebouncedTextField(
          key: ValueKey(entity.identity),
          value: entity.name,
          delay: const Duration(milliseconds: 200),
          commitValue: changeName,
          hint: messages.name,
        ),
      ).card,
      ListTile(
        leading: const Icon(Icons.category),
        title: DropdownButtonHideUnderline(
          child: DropdownButton(
            isExpanded: true,
            items: EntityType.values
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: AbsorbPointer(
                      child: Chip(
                        avatar: Ink(
                          child: Icon(
                            EntityTheme(value).icon,
                            color: EntityTheme(value).foreground,
                          ),
                        ),
                        label: Text(getEntityTypeName(value, context)),
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              changeType(value ?? entity.type);
            },
            value: entity.type,
          ),
        ),
      ).card,
      CheckboxListTile(
        title: Text(
          insight.hasLostFactor ? messages.automaticallyLost : messages.lost,
        ),
        dense: insight.hasLostFactor,
        activeColor: colors.error,
        value: entity.lost,
        selected: insight.hasLostFactor || entity.lost,
        secondary: const Icon(Icons.not_listed_location),
        onChanged: (value) {
          toggleLost(value ?? false);
        },
      ).card,
      CheckboxListTile(
        title: Text(
          insight.areAllFactorsCompromised
              ? messages.automaticallyCompromised
              : messages.compromised,
        ),
        dense: insight.areAllFactorsCompromised,
        activeColor: colors.error,
        value: entity.compromised,
        selected: entity.compromised || insight.areAllFactorsCompromised,
        secondary: const Icon(Icons.report),
        onChanged: (value) {
          toggleCompromised(value ?? false);
        },
      ).card,
      ListTile(
        title: Tip(entity.factors.isEmpty
            ? messages.noFactorsTip
            : messages.accessTip),
        dense: true,
      ),
      ...<Widget>[
        for (final (index, factor) in enumerate(entity.factors))
          DragTarget<DependableTraveler>(
            key: ValueKey(factor.identity),
            onAccept: (traveler) {
              switch (traveler) {
                case EntityTraveler traveler:
                  addDependency(factor.identity, traveler.entity);
                case DependencyTraveler traveler:
                  removeDependency(traveler.factor, traveler.entity);
                  addDependency(factor.identity, traveler.entity);
              }
            },
            builder: (context, candidate, rejected) {
              return ScaledDraggable(
                dragData: FactorTraveler(position, factor.identity),
                child: Card(
                  color: candidate.isNotEmpty ? colors.primaryContainer : null,
                  child: ListTile(
                    mouseCursor: candidate.isNotEmpty
                        ? SystemMouseCursors.copy
                        : SystemMouseCursors.grab,
                    leading: Badge(
                      isLabelVisible: entity.factors.length > 1,
                      backgroundColor: colors.primaryContainer,
                      textColor: colors.onPrimaryContainer,
                      label: Text((index + 1).toString()),
                      child: const Icon(Icons.link),
                    ),
                    title: factor.dependencies.isNotEmpty
                        ? Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              for (final entity in factor.dependencies)
                                ScaledDraggable(
                                  needsMaterial: true,
                                  dragData: DependencyTraveler(
                                    position,
                                    factor.identity,
                                    entity.identity,
                                  ),
                                  child: AbsorbPointer(
                                    child: Chip(
                                      key: ValueKey(entity.identity),
                                      label: Text(entity.name),
                                      avatar: Icon(
                                        EntityTheme(entity.type).icon,
                                        color:
                                            EntityTheme(entity.type).foreground,
                                      ),
                                    ),
                                  ),
                                ),
                            ].interleave(Tip(messages.or)).toList(),
                          )
                        : Tip(messages.emptyFactorTip),
                  ),
                ),
              );
            },
          ),
      ]
          .interleave(
            ListTile(
              title: Tip(messages.and),
              dense: true,
            ),
          )
          .toList(),
    ];

    return DragTarget<FactorableTraveler>(
      builder: (context, candidate, rejected) {
        return CardForm(children);
      },
      onWillAccept: (_) {
        hasTraveler.value = true;
        return true;
      },
      onLeave: (_) {
        hasTraveler.value = false;
      },
      onAccept: (traveler) {
        hasTraveler.value = false;
        switch (traveler) {
          case CreationTraveler _:
            addFactor();
          case EntityTraveler traveler:
            addDependencyAsFactor(traveler.entity);
          case DependencyTraveler traveler:
            removeDependency(traveler.factor, traveler.entity);
            addDependencyAsFactor(traveler.entity);
        }
      },
    );
  }
}
