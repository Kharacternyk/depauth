import 'package:flutter/material.dart';

import 'entity_chip.dart';

class EntityCell extends StatelessWidget {
  final EntityChip? child;

  const EntityCell(EntityChip this.child, {super.key});
  const EntityCell.empty({super.key}) : child = null;

  @override
  build(context) {
    return Expanded(child: child ?? const Icon(Icons.add));
  }
}
