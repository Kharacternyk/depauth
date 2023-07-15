import 'package:flutter/material.dart';

import 'core/entity.dart';
import 'core/traversable_entity.dart';

class EntityForm extends StatefulWidget {
  final TraversableEntity entity;
  final void Function(Entity) changeEntity;
  final VoidCallback deleteEntity;

  const EntityForm(
    this.entity, {
    required this.changeEntity,
    required this.deleteEntity,
    super.key,
  });

  @override
  createState() => _State();
}

class _State extends State<EntityForm> {
  late final nameController = TextEditingController(text: widget.entity.name);

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
                Entity(
                  name.trim(),
                  widget.entity.type,
                ),
              );
            },
            decoration: const InputDecoration(
              icon: Icon(Icons.edit),
              hintText: 'Name',
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
