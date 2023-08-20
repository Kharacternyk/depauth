import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/messages.dart';

import 'core/entity.dart';
import 'core/entity_insight.dart';
import 'core/entity_type.dart';
import 'core/enumerate.dart';
import 'core/factor.dart';
import 'core/position.dart';
import 'core/storage.dart';
import 'core/traveler.dart';
import 'core/traversable_entity.dart';
import 'entity_theme.dart';
import 'entity_type_name.dart';
import 'scaled_draggable.dart';

class EntityForm extends StatefulWidget {
  final TraversableEntity entity;
  final Position position;
  final EntityInsight insight;
  final void Function() goBack;
  final void Function(String) changeName;
  final void Function(EntityType) changeType;
  final void Function(bool) toggleLost;
  final void Function(bool) toggleCompromised;
  final void Function() addFactor;
  final void Function(Identity<Factor>, Identity<Entity>) addDependency;
  final void Function(Identity<Factor>, Identity<Entity>) removeDependency;

  const EntityForm(
    this.entity, {
    required this.goBack,
    required this.insight,
    required this.position,
    required this.changeName,
    required this.changeType,
    required this.toggleLost,
    required this.toggleCompromised,
    required this.addFactor,
    required this.addDependency,
    required this.removeDependency,
    super.key,
  });

  @override
  createState() => _State();
}

class _State extends State<EntityForm> {
  late var nameController = TextEditingController(text: widget.entity.name);
  Timer? _debouncer;

  @override
  dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    if (oldWidget.entity.identity != widget.entity.identity) {
      nameController = TextEditingController(text: widget.entity.name);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  build(context) {
    final colors = Theme.of(context).colorScheme;
    final messages = AppLocalizations.of(context)!;
    const tileShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(12),
      ),
    );

    final children = [
      Card(
        child: ListTile(
          leading: const BackButtonIcon(),
          title: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              Tooltip(
                message: messages.ancestorCount,
                child: Chip(
                  avatar: const Icon(Icons.arrow_upward),
                  label: Text(widget.insight.ancestorCount.toString()),
                ),
              ),
              Tooltip(
                message: messages.descendantCount,
                child: Chip(
                  avatar: const Icon(Icons.arrow_downward),
                  label: Text(widget.insight.descendantCount.toString()),
                ),
              ),
            ],
          ),
          shape: tileShape,
          onTap: widget.goBack,
        ),
      ),
      Card(
        child: ListTile(
          leading: const Icon(Icons.edit),
          title: TextField(
            controller: nameController,
            onChanged: (String name) {
              _debouncer?.cancel();
              _debouncer = Timer(const Duration(milliseconds: 200), () {
                widget.changeName(name);
              });
            },
            decoration: InputDecoration(
              hintText: messages.name,
            ),
          ),
        ),
      ),
      Card(
        child: ListTile(
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
                widget.changeType(value ?? widget.entity.type);
              },
              value: widget.entity.type,
            ),
          ),
        ),
      ),
      Card(
        child: CheckboxListTile(
          shape: tileShape,
          title: Text(
            messages.lost,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          subtitle: widget.insight.hasLostFactor
              ? Tooltip(
                  message: messages.automaticallyLost,
                  child: Row(
                    children: [
                      Text(messages.automatically),
                      const Icon(
                        Icons.info_outlined,
                        size: 16,
                      ),
                    ],
                  ),
                )
              : null,
          activeColor: colors.error,
          value: widget.entity.lost,
          selected: widget.insight.hasLostFactor || widget.entity.lost,
          secondary: const Icon(Icons.not_listed_location),
          onChanged: (value) {
            widget.toggleLost(value ?? false);
          },
        ),
      ),
      Card(
        child: CheckboxListTile(
          shape: tileShape,
          title: Text(
            messages.compromised,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          subtitle: widget.insight.areAllFactorsCompromised
              ? Tooltip(
                  message: messages.automaticallyCompromised,
                  child: Row(
                    children: [
                      Text(messages.automatically),
                      const Icon(
                        Icons.info_outlined,
                        size: 16,
                      ),
                    ],
                  ),
                )
              : null,
          activeColor: colors.error,
          value: widget.entity.compromised,
          selected: widget.entity.compromised ||
              widget.insight.areAllFactorsCompromised,
          secondary: const Icon(Icons.report),
          onChanged: (value) {
            widget.toggleCompromised(value ?? false);
          },
        ),
      ),
      for (final (index, factor) in enumerate(widget.entity.factors))
        DragTarget<DependableTraveler>(
          onAccept: (traveler) {
            switch (traveler) {
              case EntityTraveler traveler:
                widget.addDependency(factor.identity, traveler.entity);
              case DependencyTraveler traveler:
                widget.removeDependency(traveler.factor, traveler.entity);
                widget.addDependency(factor.identity, traveler.entity);
            }
          },
          builder: (context, candidate, rejected) {
            return ScaledDraggable(
              dragData: FactorTraveler(widget.position, factor.identity),
              child: Card(
                color: candidate.isNotEmpty ? colors.primaryContainer : null,
                child: ListTile(
                  mouseCursor: candidate.isNotEmpty
                      ? SystemMouseCursors.copy
                      : SystemMouseCursors.grab,
                  leading: Badge(
                    isLabelVisible: widget.entity.factors.length > 1,
                    backgroundColor: colors.primaryContainer,
                    textColor: colors.onPrimaryContainer,
                    label: Text((index + 1).toString()),
                    child: const Icon(Icons.link),
                  ),
                  title: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (final entity in factor.dependencies)
                        ScaledDraggable(
                          needsMaterial: true,
                          dragData: DependencyTraveler(
                            widget.position,
                            factor.identity,
                            entity.identity,
                          ),
                          child: AbsorbPointer(
                            child: Chip(
                              key: ValueKey(entity.identity),
                              label: Text(entity.name),
                              avatar: Icon(
                                EntityTheme(entity.type).icon,
                                color: EntityTheme(entity.type).foreground,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
    ];

    return DragTarget<CreationTraveler>(
      builder: (context, candidate, rejected) {
        return ListView(
          children: [
            ...children,
            if (candidate.isNotEmpty)
              Card(
                child: ListTile(
                  leading: Badge(
                    backgroundColor: colors.primaryContainer,
                    textColor: colors.onPrimaryContainer,
                    label: const Text("+"),
                    child: const Icon(Icons.link),
                  ),
                ),
              ),
          ],
        );
      },
      onAccept: (_) {
        widget.addFactor();
      },
    );
  }
}
