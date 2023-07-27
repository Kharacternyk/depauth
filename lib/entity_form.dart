import 'dart:async';

import 'package:flutter/material.dart';

import 'core/db.dart';
import 'core/entity.dart';
import 'core/entity_type.dart';
import 'core/enumerate.dart';
import 'core/factor.dart';
import 'core/position.dart';
import 'core/traveler.dart';
import 'core/traversable_entity.dart';
import 'entity_theme.dart';
import 'scaled_draggable.dart';

class EntityForm extends StatefulWidget {
  final TraversableEntity entity;
  final Position position;
  final void Function(Entity) changeEntity;
  final void Function() addFactor;
  final void Function(Id<Factor>, Id<Entity>) addDependency;
  final void Function(Id<Factor>, Id<Entity>) removeDependency;

  const EntityForm(
    this.entity, {
    required this.position,
    required this.changeEntity,
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
    if (oldWidget.entity.id != widget.entity.id) {
      nameController = TextEditingController(text: widget.entity.name);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  build(context) {
    final colors = Theme.of(context).colorScheme;

    final children = [
      Card(
        child: ListTile(
          leading: const Icon(Icons.edit),
          title: TextField(
            controller: nameController,
            onChanged: (String name) {
              _debouncer?.cancel();
              _debouncer = Timer(const Duration(milliseconds: 200), () {
                widget.changeEntity(
                  Entity(name, widget.entity.type),
                );
              });
            },
            decoration: const InputDecoration(
              hintText: 'Name',
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
                      child: Chip(
                        avatar: Ink(
                          child: Icon(
                            EntityTheme(value).icon,
                            color: EntityTheme(value).foreground,
                          ),
                        ),
                        label: Text(EntityTheme(value).typeName),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                widget.changeEntity(
                  Entity(widget.entity.name, value ?? widget.entity.type),
                );
              },
              value: widget.entity.type,
            ),
          ),
        ),
      ),
      for (final (index, factor) in enumerate(widget.entity.factors))
        DragTarget<DependableTraveler>(
          onAccept: (traveler) {
            switch (traveler) {
              case EntityTraveler traveler:
                widget.addDependency(factor.id, traveler.id);
              case DependencyTraveler traveler:
                widget.removeDependency(traveler.factorId, traveler.entityId);
                widget.addDependency(factor.id, traveler.entityId);
            }
          },
          builder: (context, candidate, rejected) {
            return ScaledDraggable(
              dragData: FactorTraveler(widget.position, factor.id),
              child: Card(
                color: candidate.isNotEmpty ? colors.primaryContainer : null,
                child: ListTile(
                  leading: Badge(
                    isLabelVisible: widget.entity.factors.length > 1,
                    backgroundColor: colors.primaryContainer,
                    textColor: colors.onPrimaryContainer,
                    label: Text((index + 1).toString()),
                    child: const Icon(Icons.link),
                  ),
                  title: Wrap(
                    key: ValueKey(factor.id),
                    spacing: 4,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (final entity in factor.dependencies)
                        ScaledDraggable(
                          needsMaterial: true,
                          dragData: DependencyTraveler(
                            widget.position,
                            factor.id,
                            entity.id,
                          ),
                          child: Chip(
                            key: ValueKey(entity.id),
                            label: Text(entity.name),
                            avatar: Icon(
                              EntityTheme(entity.type).icon,
                              color: EntityTheme(entity.type).foreground,
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
