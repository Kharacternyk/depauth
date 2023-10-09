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
import 'core/title_case.dart';
import 'core/traveler.dart';
import 'core/traversable_entity.dart';
import 'debounced_text_field.dart';
import 'entity_theme.dart';
import 'entity_type_name.dart';
import 'scaled_draggable.dart';
import 'widget_extension.dart';

class EntityForm extends StatelessWidget {
  final TraversableEntity entity;
  final Position position;
  final EntityInsight insight;
  final ValueNotifier<bool> hasTraveler;
  final void Function() goBack;
  final void Function(String) changeName;
  final void Function(EntityType) changeType;
  final void Function(int) changeImportance;
  final void Function(bool) toggleLost;
  final void Function(bool) toggleCompromised;
  final void Function() addFactor;
  final void Function(Identity<Entity>) addDependencyAsFactor;
  final void Function(Identity<Factor>, Identity<Entity>) addDependency;
  final void Function(Identity<Factor>, Identity<Entity>) removeDependency;
  final bool Function() isRenameCanceled;

  const EntityForm(
    this.entity, {
    required this.hasTraveler,
    required this.goBack,
    required this.insight,
    required this.position,
    required this.changeName,
    required this.changeType,
    required this.changeImportance,
    required this.toggleLost,
    required this.toggleCompromised,
    required this.addFactor,
    required this.addDependencyAsFactor,
    required this.addDependency,
    required this.removeDependency,
    required this.isRenameCanceled,
    super.key,
  });

  @override
  build(context) {
    final colors = Theme.of(context).colorScheme;
    final messages = AppLocalizations.of(context)!;

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
          commitValue: changeName,
          hint: messages.name,
          isCanceled: isRenameCanceled,
        ),
      ).card,
      ListTile(
        leading: const Icon(Icons.category),
        title: DropdownButtonHideUnderline(
          child: DropdownButton(
            isExpanded: true,
            items: [
              for (final value in EntityType.values)
                DropdownMenuItem(
                  value: value,
                  child: AbsorbPointer(
                    child: Chip(
                      avatar: Ink(
                        child: Icon(
                          value.icon,
                          color: value.primaryColor,
                        ),
                      ),
                      label: Text(
                        value.getName(context).title(messages.wordSeparator),
                      ),
                    ),
                  ),
                ),
            ],
            onChanged: (value) {
              changeType(value ?? entity.type);
            },
            value: entity.type,
          ),
        ),
      ).card,
      ListTile(
        leading: const Icon(Icons.star),
        title: Slider(
          min: 0,
          max: 5,
          divisions: 5,
          value: entity.importance.toDouble(),
          onChanged: (value) => changeImportance(value.round()),
        ),
      ).card,
      SwitchListTile(
        title: Text(
          insight.hasLostFactor
              ? messages.automaticallyLost(entity.type.getName(context))
              : messages.lost,
        ),
        activeColor: colors.error,
        value: entity.lost,
        selected: insight.hasLostFactor || entity.lost,
        secondary: const Icon(Icons.not_listed_location),
        onChanged: toggleLost,
      ).card,
      SwitchListTile(
        title: Text(
          insight.areAllFactorsCompromised
              ? messages.automaticallyCompromised(entity.type.getName(context))
              : messages.compromised,
        ),
        activeColor: colors.error,
        value: entity.compromised,
        selected: entity.compromised || insight.areAllFactorsCompromised,
        secondary: const Icon(Icons.report),
        onChanged: toggleCompromised,
      ).card,
      ListTile(
        title: Text(
          entity.factors.isEmpty
              ? messages.noFactorsTip(entity.type.getName(context))
              : messages.accessTip(
                  entity.type.getName(context),
                ),
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      ),
      ...<Widget>[
        for (final (index, factor) in entity.factors.enumerate)
          DragTarget<DependableTraveler>(
            key: ValueKey(factor.identity),
            onWillAccept: (traveler) {
              if (traveler case EntityTraveler traveler
                  when traveler.entity == entity.identity) {
                return false;
              }
              return true;
            },
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
                                  key: ValueKey(entity.identity),
                                  needsMaterial: true,
                                  dragData: DependencyTraveler(
                                    position,
                                    factor.identity,
                                    entity.identity,
                                  ),
                                  child: AbsorbPointer(
                                    child: Chip(
                                      label: Text(entity.name),
                                      avatar: Icon(
                                        entity.type.icon,
                                        color: entity.type.primaryColor,
                                      ),
                                    ),
                                  ),
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
            when traveler.entity == entity.identity) {
          return false;
        }
        return hasTraveler.value = true;
      },
      onLeave: (_) => hasTraveler.value = false,
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
