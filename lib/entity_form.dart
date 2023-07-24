import 'dart:async';

import 'package:flutter/material.dart';

import 'core/db.dart';
import 'core/entity.dart';
import 'core/entity_type.dart';
import 'core/factor.dart';
import 'core/traversable_entity.dart';
import 'core/unique_entity.dart';
import 'entity_theme.dart';

class EntityForm extends StatefulWidget {
  final TraversableEntity entity;
  final void Function() closeItself;
  final void Function(Entity) changeEntity;
  final void Function() deleteEntity;
  final void Function(Id<Factor>, Id<Entity>) deleteDependency;
  final void Function(Id<Factor>, Id<Entity>) addDependency;
  final Iterable<UniqueEntity> Function(Id<Factor>) getPossibleDependencies;

  const EntityForm(
    this.entity, {
    required this.closeItself,
    required this.changeEntity,
    required this.deleteEntity,
    required this.deleteDependency,
    required this.addDependency,
    required this.getPossibleDependencies,
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
    return Material(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
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
          DropdownButtonHideUnderline(
            child: DropdownButton(
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
          for (final factor in widget.entity.factors)
            Wrap(
              key: ValueKey(factor.id),
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final entity in factor.dependencies)
                  Chip(
                    key: ValueKey(entity.id),
                    label: Text(entity.name),
                    avatar: Icon(
                      EntityTheme(entity.type).icon,
                      color: EntityTheme(entity.type).foreground,
                    ),
                    onDeleted: () {
                      widget.deleteDependency(factor.id, entity.id);
                    },
                  ),
                PopupMenuButton(
                  onSelected: (entity) {
                    if (entity case UniqueEntity entity) {
                      widget.addDependency(factor.id, entity.id);
                    }
                  },
                  icon: const Icon(Icons.add),
                  itemBuilder: (context) {
                    return [
                      for (final entity
                          in widget.getPossibleDependencies(factor.id))
                        PopupMenuItem(
                          value: entity,
                          child: Chip(
                            key: ValueKey(entity.id),
                            label: Text(entity.name),
                            avatar: Icon(
                              EntityTheme(entity.type).icon,
                              color: EntityTheme(entity.type).foreground,
                            ),
                          ),
                        )
                    ];
                  },
                )
              ],
            ),
          IconButton(
            onPressed: widget.deleteEntity,
            icon: const Icon(Icons.delete),
            color: Theme.of(context).colorScheme.error,
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }
}
