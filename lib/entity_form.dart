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
          child: TextFormField(
            controller: nameController,
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
                    widget.changeEntity(
                      Entity(
                        nameController.text,
                        widget.entity.type,
                      ),
                    );
                    Navigator.maybePop(context);
                  },
                  icon: const Icon(Icons.save),
                  color: Theme.of(context).colorScheme.primary,
                  tooltip: "Save",
                ),
              ),
              const Expanded(child: CloseButton()),
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
