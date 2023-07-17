import 'package:flutter/material.dart';

import 'core/entity.dart';
import 'core/entity_type.dart';
import 'core/traversable_entity.dart';
import 'core/unique_entity.dart';
import 'entity_theme.dart';

class EntityForm extends StatefulWidget {
  final TraversableEntity entity;
  final void Function(Entity) changeEntity;
  final void Function() deleteEntity;
  final void Function({
    required int entityId,
    required int factorId,
  }) deleteDependency;

  const EntityForm(
    this.entity, {
    required this.changeEntity,
    required this.deleteEntity,
    required this.deleteDependency,
    super.key,
  });

  @override
  createState() => _State();
}

class _State extends State<EntityForm> {
  late final nameController = TextEditingController(text: widget.entity.name);
  late EntityType type = widget.entity.type;
  late final Map<int, Map<int, UniqueEntity>> dependencies = {
    for (final factor in widget.entity.factors)
      factor.id: {
        for (final dependency in factor.dependencies) dependency.id: dependency
      }
  };

  @override
  dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  build(context) {
    return SimpleDialog(
      children: [
        SimpleDialogOption(
          child: TextField(
            controller: nameController,
            onChanged: (String name) {
              widget.changeEntity(
                Entity(name, type),
              );
            },
            decoration: const InputDecoration(
              hintText: 'Name',
            ),
          ),
        ),
        SimpleDialogOption(
          child: DropdownButtonHideUnderline(
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
                  Entity(nameController.text, value ?? widget.entity.type),
                );
                setState(() {
                  type = value ?? widget.entity.type;
                });
              },
              value: type,
            ),
          ),
        ),
        for (final factor in dependencies.entries)
          SimpleDialogOption(
            key: ValueKey(factor.key),
            child: Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  const ListTile(title: Text('Factor')),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: factor.value.values.map((entity) {
                      return Chip(
                        key: ValueKey(entity.id),
                        label: Text(entity.name),
                        avatar: Icon(
                          EntityTheme(entity.type).icon,
                          color: EntityTheme(entity.type).foreground,
                        ),
                        onDeleted: () {
                          widget.deleteDependency(
                            factorId: factor.key,
                            entityId: entity.id,
                          );
                          setState(() {
                            dependencies[factor.key]?.remove(entity.id);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        SimpleDialogOption(
          child: Row(
            children: [
              Expanded(
                child: IconButton(
                  onPressed: () {
                    Navigator.maybePop(context);
                  },
                  icon: const Icon(Icons.done),
                  color: Theme.of(context).colorScheme.primary,
                  tooltip: "Done",
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {
                    nameController.text = widget.entity.name;
                    setState(() {
                      type = widget.entity.type;
                    });
                    widget.changeEntity(widget.entity);
                  },
                  icon: const Icon(Icons.undo),
                  tooltip: "Undo all changes",
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: () {
                    widget.deleteEntity();
                    Navigator.maybePop(context);
                  },
                  icon: const Icon(Icons.delete),
                  color: Theme.of(context).colorScheme.error,
                  tooltip: "Delete",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
