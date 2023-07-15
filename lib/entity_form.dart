import 'package:flutter/material.dart';

import 'core/entity.dart';
import 'core/traversable_entity.dart';

class EntityForm extends StatefulWidget {
  final TraversableEntity entity;
  final void Function(Entity) changeEntity;

  const EntityForm(
    this.entity, {
    required this.changeEntity,
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
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
          ),
          ElevatedButton(
            onPressed: () {
              widget.changeEntity(
                Entity(
                  nameController.text,
                  widget.entity.type,
                ),
              );
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }
}
