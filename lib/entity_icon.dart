import 'package:flutter/material.dart';

import 'core/entity_type.dart';
import 'entity_theme.dart';
import 'widget_extension.dart';

class EntityIcon extends StatelessWidget {
  final EntityType type;
  final EdgeInsets padding;

  const EntityIcon(this.type, {required this.padding, super.key});

  @override
  build(context) {
    return Ink(
      color: type.theme.colorScheme.primaryContainer,
      child: Icon(
        type.icon,
        color: type.theme.colorScheme.onPrimaryContainer,
      ).pad(padding).fit.grow,
    );
  }
}
